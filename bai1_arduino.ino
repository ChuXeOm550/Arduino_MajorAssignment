#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>

// Cấu hình WiFi
#define WIFI_SSID "Galaxy A23 1CFF"
#define WIFI_PASSWORD "hoaian0123"

// Cấu hình Firebase
#define FIREBASE_HOST "esp8266-7280d-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "42NYpgaX0hdhBdRd94pxhyNK42mr9e4m7xxtZ01L"

// Chọn chân LED để điều chỉnh độ sáng (D2 là chân hỗ trợ PWM)
#define LED_PIN_1 4
#define BUZZER_PIN 14  // Chân GPIO14 (D5) dùng cho loa
#define LED_PIN_2 13

int brightness = 0;
int blinkSpeed = 500;  // Thời gian chớp LED mặc định là 500ms (tốc độ)

FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;

void setup() {
  Serial.begin(115200);

  // Kết nối WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Đang kết nối WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nKết nối WiFi thành công!");

  // Cấu hình Firebase
  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;

  // Bắt đầu Firebase
  Firebase.begin(&firebaseConfig, &firebaseAuth);
  Firebase.reconnectWiFi(true);

  // Khởi tạo LED và Buzzer
  pinMode(LED_PIN_1, OUTPUT); // Chân LED BUILTIN này hiện là led tích hợp của esp nên nó bị đảo ngược
  pinMode(LED_PIN_2, OUTPUT); // Chân LED BUILTIN này hiện là led tích hợp của esp nên nó bị đảo ngược
  pinMode(BUZZER_PIN, OUTPUT);  // Chân Buzzer
}

void loop() {
  // Đọc trạng thái LED từ Firebase
  if (Firebase.getInt(firebaseData, "/led/status")) {
    int ledStatus = firebaseData.intData();

    // Nếu LED được bật, điều chỉnh độ sáng LED
    if (ledStatus == 1) {
      if (Firebase.getInt(firebaseData, "/led/brightness")) {
        brightness = firebaseData.intData();
        brightness = constrain(brightness, 0, 255); // Giới hạn độ sáng từ 0-255
        analogWrite(LED_PIN_2, brightness);          // Điều chỉnh độ sáng LED
        Serial.print("Độ sáng hiện tại: ");
        Serial.println(brightness);
      } else {
        Serial.println("Không thể đọc độ sáng: " + firebaseData.errorReason());
      }

      // Đọc tốc độ chớp LED từ Firebase
      if (Firebase.getInt(firebaseData, "/led/blink_speed")) {
        blinkSpeed = firebaseData.intData();
        Serial.print("Tốc độ chớp LED: ");
        Serial.println(blinkSpeed);
      } else {
        Serial.println("Không thể đọc tốc độ chớp: " + firebaseData.errorReason());
      }

      // Chớp LED với tốc độ được điều chỉnh
      digitalWrite(LED_PIN_1, HIGH); // Bật LED
      delay(blinkSpeed);           // Chờ thời gian chớp
      digitalWrite(LED_PIN_1, LOW);  // Tắt LED
      delay(blinkSpeed);           // Chờ thời gian chớp
    } else {
      digitalWrite(LED_PIN_1, LOW); // Tắt LED nếu trạng thái là tắt
      digitalWrite(LED_PIN_2, LOW); // Tắt LED nếu trạng thái là tắt
      Serial.println("LED đã tắt.");
    }
  } else {
    Serial.println("Không thể đọc trạng thái LED: " + firebaseData.errorReason());
  }

  // Đọc trạng thái Loa (Buzzer) từ Firebase
  if (Firebase.getInt(firebaseData, "/buzzer/status")) {
    int buzzerStatus = firebaseData.intData();

    // Bật loa nếu trạng thái là 1, tắt nếu trạng thái là 0
    if (buzzerStatus == 1) {
      digitalWrite(BUZZER_PIN, HIGH);  // Bật loa
      Serial.println("Loa đã bật.");
    } else {
      digitalWrite(BUZZER_PIN, LOW);   // Tắt loa
      Serial.println("Loa đã tắt.");
    }
  } else {
    Serial.println("Không thể đọc trạng thái Loa: " + firebaseData.errorReason());
  }

  delay(1000); // Giảm tải Firebase
}
