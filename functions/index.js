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
const EmailEndpoint = process.env.EMAIL_ENDPOINT;
const OwnerEmailEndpoint = process.env.OWNER_EMAIL_ENDPOINT;
const UidEndpoint = process.env.UID_ENDPOINT;
const region = process.env.REGION;

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
async function encrypt(text) {
  const aesKey = await getAesKey();
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(
    "aes-256-cbc",
    Buffer.from(aesKey, "base64"),
    iv
  );

  let encrypted = cipher.update(text, "utf-8", "base64");
  encrypted += cipher.final("base64");

  return {
    iv: iv.toString("base64"),
    encryptedData: encrypted,
  };
}

/**
 * AES 복호화 함수
 * @param {string} encryptedData - 복호화할 암호화된 데이터
 * @param {string} iv - 암호화에 사용된 IV
 * @return {Promise<string>} 복호화된 텍스트를 반환합니다.
 */
async function decrypt(encryptedData, iv) {
  const aesKey = await getAesKey();
  const decipher = crypto.createDecipheriv(
    "aes-256-cbc",
    Buffer.from(aesKey, "base64"),
    Buffer.from(iv, "base64")
  );

  let decrypted = decipher.update(
    Buffer.from(encryptedData, "base64"),
    "base64",
    "utf-8"
  );
  decrypted += decipher.final("utf-8");
  return decrypted;
}

/**
 * 오류 응답을 처리하는 함수
 * @param {Object} res - Express 응답 객체
 * @param {Error} error - 발생한 오류 객체
 * @param {string} message - 사용자에게 전달할 메시지
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
 * @param {string} collection - 컬렉션 이름 ('users' 또는 'owners')
 * @param {string} field - 검색할 필드명 ('email' 또는 'uid')
 * @param {string} value - 필드 값
 * @return {Promise<Object>} 사용자 데이터 객체를 반환합니다.
 */
async function getUserData(collection, field, value) {
  const usersRef = admin.firestore().collection(collection);
  const snapshot = await usersRef
    .where(field, "==", value)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return {exists: false};
  }

  const userData = snapshot.docs[0].data();
  return {
    exists: true,
    userData: userData,
  };
}

// /encrypt 엔드포인트 - 데이터를 암호화
exports[encryptEndpoint] = functions.https.onRequest(
  {
    region:region,
  },
  async (req, res) => {
    try {
      const data = req.body.data;
      const jsonString =
        typeof data === "string" ? data : JSON.stringify(data);

      const encrypted = await encrypt(jsonString);
      res.status(200).send({
        encryptedData: encrypted.encryptedData,
        iv: encrypted.iv,
      });
    } catch (error) {
      handleError(res, error, "암호화에 실패했습니다.");
    }
  }
);

// /decrypt 엔드포인트 - 데이터를 복호화
exports[decryptEndpoint] = functions.https.onRequest(
  {
    region:region,
  },
  async (req, res) => {
    try {
      const {encryptedData, iv} = req.body;
      if (!encryptedData || !iv) {
        throw new Error(
          "암호화된 데이터 또는 IV가 제공되지 않았습니다."
        );
      }

      const decrypted = await decrypt(encryptedData, iv);
      res.status(200).send({
        decrypted,
      });
    } catch (error) {
      handleError(res, error, "복호화에 실패했습니다.");
    }
  }
);

// email을 통해 유저 정보 검색
exports[EmailEndpoint] = functions.https.onCall(
  {
    region:region,
  },
  async (request) => {
    try {
      const email = request.data.email;
      if (!email) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "이메일이 제공되지 않았습니다."
        );
      }

      return await getUserData("users", "email", email);
    } catch (error) {
      console.error("이메일 존재 여부 확인 오류:", error);
      throw new functions.https.HttpsError(
        "internal",
        "이메일 존재 여부 확인에 실패했습니다.",
        error.message
      );
    }
  }
);

// email을 통해 오너 정보 검색
exports[OwnerEmailEndpoint] = functions.https.onCall(
  {
    region:region,
  },
  async (request) => {
    try {
      const email = request.data.email;
      if (!email) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "이메일이 제공되지 않았습니다."
        );
      }

      return await getUserData("owners", "email", email);
    } catch (error) {
      console.error("오너 이메일 존재 여부 확인 오류:", error);
      throw new functions.https.HttpsError(
        "internal",
        "오너 이메일 존재 여부 확인에 실패했습니다.",
        error.message
      );
    }
  }
);

// uid를 통해 유저 정보 검색
exports[UidEndpoint] = functions.https.onCall(
  {
    region:region,
  },
  async (request) => {
    try {
      const uid = request.data.uid;
      if (!uid) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "UID가 제공되지 않았습니다."
        );
      }

      return await getUserData("users", "uid", uid);
    } catch (error) {
      console.error("UID 존재 여부 확인 오류:", error);
      throw new functions.https.HttpsError(
        "internal",
        "UID 존재 여부 확인에 실패했습니다.",
        error.message
      );
    }
  }
);
