require("dotenv").config();
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const {SecretManagerServiceClient} = require("@google-cloud/secret-manager");

admin.initializeApp();
const client = new SecretManagerServiceClient();

let cachedAesKey = null;
/**
 * Secret Manager에서 AES 키를 가져오는 함수
 * @return {Promise<string>} AES 키를 반환합니다.
 */
async function getAesKey() {
  if (cachedAesKey) return cachedAesKey;

  const [accessResponse] = await client.accessSecretVersion({
    name: process.env.SECRET_MANAGER_PATH,
  });
  cachedAesKey = accessResponse.payload.data.toString("utf8");
  return cachedAesKey;
}

// AES 암호화 함수
const encrypt = async (text) => {
  const aesKey = await getAesKey();
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv("aes-256-cbc",
      Buffer.from(aesKey, "base64"), iv);

  let encrypted = cipher.update(text, "utf-8", "base64");
  encrypted += cipher.final("base64");

  return {
    iv: iv.toString("base64"),
    encryptedData: encrypted,
  };
};

// /encrypt 엔드포인트 - 데이터를 암호화
exports.encryptData = functions.https.onRequest(async (req, res) => {
  try {
    const data = req.body.data;

    let jsonString;
    try {
      jsonString = typeof data === "string" ? data : JSON.stringify(data);
    } catch (error) {
      console.error("암호화 오류:", error);
      return res.status(400).send({
        error: "잘못된 데이터 형식입니다.",
        details: error.message,
      });
    }

    const encrypted = await encrypt(jsonString);
    res.status(200).send({
      encryptedData: encrypted.encryptedData,
      iv: encrypted.iv,
    });
  } catch (error) {
    console.error("암호화 오류:", error);
    res.status(500).send({
      error: "암호화에 실패했습니다.",
      details: error.message,
    });
  }
});

// AES 복호화 함수
const decrypt = async (encryptedData, iv) => {
  const aesKey = await getAesKey(); // Secret Manager에서 AES 키 가져오기
  const decipher = crypto.createDecipheriv("aes-256-cbc",
      Buffer.from(aesKey, "base64"), Buffer.from(iv, "base64"));

  let decrypted = decipher.update(Buffer.from(encryptedData, "base64"),
      "base64", "utf-8");
  decrypted += decipher.final("utf-8");
  return decrypted;
};

// /decrypt 엔드포인트 - 데이터를 복호화
exports.decryptData = functions.https.onRequest(async (req, res) => {
  try {
    const {encryptedData, iv} = req.body;

    if (!encryptedData || !iv) {
      throw new Error("암호화된 데이터 또는 IV가 제공되지 않았습니다.");
    }

    const decrypted = await decrypt(encryptedData, iv);
    res.status(200).send({decrypted});
  } catch (error) {
    console.error("복호화 오류:", error);
    res.status(500).send({
      error: "복호화에 실패했습니다.",
      details: error.message,
    });
  }
});
