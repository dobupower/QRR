const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto"); // AES 키를 생성하기 위해 필요
admin.initializeApp();

// AES 암호화 함수
const encrypt = (text, aesKey) => {
  const iv = crypto.randomBytes(16); // IV 생성
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

// 환경 변수에서 AES 키 가져오기
const aesKey = functions.config().security.aes_key;

// /encrypt 엔드포인트 - 데이터를 암호화
exports.encryptData = functions.https.onRequest(async (req, res) => {
  try {
    // 클라이언트에서 전송한 데이터
    const data = req.body.data;

    // 데이터가 문자열로 변환 가능한 JSON인지 확인
    let jsonString;
    try {
      jsonString = typeof data === "string" ?
      data : JSON.stringify(data); // 문자열로 변환
    } catch (error) {
      return res.status(400).send({
        error: "잘못된 데이터 형식입니다.",
        details: error.message,
      });
    }

    // 데이터 암호화
    const encrypted = encrypt(jsonString, aesKey);

    // 암호화된 데이터를 전송 (iv와 encryptedData를 별도로 구분)
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
const decrypt = (encryptedData, iv, aesKey) => {
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
exports.decryptData = functions.https.onRequest(async (req, res) => {
  try {
    // 클라이언트에서 전송된 암호화된 데이터와 IV
    const {encryptedData, iv} = req.body;

    console.log("Received encryptedData:", encryptedData);
    console.log("Received iv:", iv);

    // 데이터가 제대로 전달되었는지 확인
    if (!encryptedData || !iv) {
      throw new Error("암호화된 데이터 또는 IV가 제공되지 않았습니다.");
    }

    const decrypted = decrypt(encryptedData, iv, aesKey); // 데이터 복호화

    res.status(200).send({decrypted});
  } catch (error) {
    console.error("복호화 오류:", error);
    res.status(500).send({
      error: "복호화에 실패했습니다.",
      details: error.message,
    });
  }
});
