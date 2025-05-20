require("dotenv").config();
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const crypto = require("crypto");
const { SecretManagerServiceClient } = require("@google-cloud/secret-manager");

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

/**
 * AES 암호화 함수
 */
async function encrypt(text) {
  const aesKey = await getAesKey();
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv("aes-256-cbc", Buffer.from(aesKey, "base64"), iv);

  let encrypted = cipher.update(text, "utf-8", "base64");
  encrypted += cipher.final("base64");

  return {
    iv: iv.toString("base64"),
    encryptedData: encrypted,
  };
}

/**
 * AES 복호화 함수
 */
async function decrypt(encryptedData, iv) {
  const aesKey = await getAesKey();
  const decipher = crypto.createDecipheriv(
    "aes-256-cbc",
    Buffer.from(aesKey, "base64"),
    Buffer.from(iv, "base64")
  );

  let decrypted = decipher.update(Buffer.from(encryptedData, "base64"), "base64", "utf-8");
  decrypted += decipher.final("utf-8");
  return decrypted;
}

/**
 * 에러 처리 함수
 */
function handleError(res, error, message) {
  console.error(message, error);
  res.status(500).send({
    error: message,
    details: error.message,
  });
}

/**
 * Firestore에서 사용자 데이터를 가져오는 공통 함수
 */
async function getUserData(collection, field, value) {
  const usersRef = admin.firestore().collection(collection);
  const snapshot = await usersRef.where(field, "==", value).limit(1).get();

  if (snapshot.empty) {
    return { exists: false };
  }

  const userData = snapshot.docs[0].data();
  return {
    exists: true,
    userData: userData,
  };
}

const REGION = "asia-northeast1";

// 암호화 함수
exports.encrypt = functions.https.onRequest({ region: REGION }, async (req, res) => {
  try {
    const data = req.body.data;
    const jsonString = typeof data === "string" ? data : JSON.stringify(data);

    const encrypted = await encrypt(jsonString);
    res.status(200).send({
      encryptedData: encrypted.encryptedData,
      iv: encrypted.iv,
    });
  } catch (error) {
    handleError(res, error, "암호화에 실패했습니다.");
  }
});

// 복호화 함수
exports.decrypt = functions.https.onRequest({ region: REGION }, async (req, res) => {
  try {
    const { encryptedData, iv } = req.body;
    if (!encryptedData || !iv) {
      throw new Error("암호화된 데이터 또는 IV가 제공되지 않았습니다.");
    }

    const decrypted = await decrypt(encryptedData, iv);
    res.status(200).send({ decrypted });
  } catch (error) {
    handleError(res, error, "복호화에 실패했습니다.");
  }
});

// 사용자 이메일 조회
exports.emailLookup = functions.https.onCall({ region: REGION }, async (request) => {
  try {
    const email = request.data.email;
    if (!email) {
      throw new functions.https.HttpsError("invalid-argument", "이메일이 제공되지 않았습니다.");
    }

    return await getUserData("users", "email", email);
  } catch (error) {
    console.error("이메일 존재 여부 확인 오류:", error);
    throw new functions.https.HttpsError("internal", "이메일 존재 여부 확인에 실패했습니다.", error.message);
  }
});

// 오너 이메일 조회
exports.ownerEmailLookup = functions.https.onCall({ region: REGION }, async (request) => {
  try {
    const email = request.data.email;
    if (!email) {
      throw new functions.https.HttpsError("invalid-argument", "이메일이 제공되지 않았습니다.");
    }

    return await getUserData("owners", "email", email);
  } catch (error) {
    console.error("오너 이메일 존재 여부 확인 오류:", error);
    throw new functions.https.HttpsError("internal", "오너 이메일 존재 여부 확인에 실패했습니다.", error.message);
  }
});

// UID 조회
exports.uidLookup = functions.https.onCall({ region: REGION }, async (request) => {
  try {
    const uid = request.data.uid;
    if (!uid) {
      throw new functions.https.HttpsError("invalid-argument", "UID가 제공되지 않았습니다.");
    }

    return await getUserData("users", "uid", uid);
  } catch (error) {
    console.error("UID 존재 여부 확인 오류:", error);
    throw new functions.https.HttpsError("internal", "UID 존재 여부 확인에 실패했습니다.", error.message);
  }
});
