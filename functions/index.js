require("dotenv").config();
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const crypto = require("crypto");
const {SecretManagerServiceClient} = require("@google-cloud/secret-manager");

admin.initializeApp();
const client = new SecretManagerServiceClient();

let cachedAesKey = null;

// 환경 변수로 설정된 엔드포인트 가져오기
const encryptEndpoint = process.env.ENCRYPT_ENDPOINT;
const decryptEndpoint = process.env.DECRYPT_ENDPOINT;

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

/**
 * AES 암호화 함수
 * @param {string} text - 암호화할 텍스트
 * @return {Promise<Object>} 암호화된 데이터와 IV를 포함한 객체를 반환합니다.
 */
const encrypt = async (text) => {
  const aesKey = await getAesKey();
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(
      "aes-256-cbc",
      Buffer.from(aesKey, "base64"),
      iv,
  );

  let encrypted = cipher.update(text, "utf-8", "base64");
  encrypted += cipher.final("base64");

  return {
    iv: iv.toString("base64"),
    encryptedData: encrypted,
  };
};

// /encrypt 엔드포인트 - 데이터를 암호화
exports[encryptEndpoint] = functions.https.onRequest(
    {
      region: "asia-northeast1", // 지역 설정
    },
    async (req, res) => {
      try {
        const data = req.body.data;
        const jsonString = typeof data === "string" ?
         data : JSON.stringify(data);

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

/**
 * AES 복호화 함수
 * @param {string} encryptedData - 복호화할 암호화된 데이터
 * @param {string} iv - 암호화에 사용된 IV
 * @return {Promise<string>} 복호화된 텍스트를 반환합니다.
 */
const decrypt = async (encryptedData, iv) => {
  const aesKey = await getAesKey();
  const decipher = crypto.createDecipheriv(
      "aes-256-cbc",
      Buffer.from(aesKey, "base64"),
      Buffer.from(iv, "base64"),
  );

  let decrypted = decipher.update(
      Buffer.from(encryptedData, "base64"),
      "base64",
      "utf-8",
  );
  decrypted += decipher.final("utf-8");
  return decrypted;
};

// /decrypt 엔드포인트 - 데이터를 복호화
exports[decryptEndpoint] = functions.https.onRequest(
    {
      region: "asia-northeast1", // 지역 설정
    },
    async (req, res) => {
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
