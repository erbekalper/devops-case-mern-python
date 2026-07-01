# DevOps Case - MERN Stack ve Python ETL Deployment

Bu repository, bana verilen DevOps case çalışması için hazırlanmıştır.

Case kapsamında iki farklı proje vardı:

1. MERN Stack uygulaması
   - React frontend
   - Express.js / Node.js backend
   - MongoDB database

2. Python projesi
   - ETL.py dosyası
   - Her 1 saatte bir otomatik çalışması gerekiyor

Ben bu çalışmada verilen uygulamaları Docker ile container haline getirdim, Kubernetes üzerinde çalıştırdım, AWS EC2 sunucusuna deploy ettim ve GitHub Actions ile CI/CD sürecini otomatikleştirdim. Ayrıca monitoring ve alerting tarafında Prometheus, Grafana ve Telegram bildirimi kullandım.

---

## Genel Mimari

Projeyi AWS üzerinde bir EC2 sanal makineye kurdum. EC2 üzerinde Ubuntu Server var. Kubernetes için daha hafif ve tek node ortamlar için uygun olduğu için k3s kullandım.

Genel akış şu şekilde:

```text
Kullanıcı
  |
  | http://EC2_PUBLIC_IP:30080
  v
React Frontend
  |
  | API request
  v
Express.js Backend
  |
  | MongoDB connection
  v
MongoDB


Python ETL
  |
  v
Kubernetes CronJob
Her 1 saatte bir çalışır


Monitoring / Alerting
  |
  |-- Prometheus
  |-- Grafana
  |-- Telegram Notification
```

---

## Kullandığım Teknolojiler

Bu case için kullandığım teknolojiler:

```text
AWS EC2
Ubuntu Server
Docker
Kubernetes / k3s
React
Node.js
Express.js
MongoDB
Python
GitHub Actions
Prometheus
Grafana
Telegram Bot
Terraform
```

---

## Repository Yapısı

Repo içinde dosya yapısı genel olarak şu şekildedir:

```text
.github/
  workflows/
    ci-cd.yml

k8s/
  namespace.yaml
  mongodb.yaml
  backend.yaml
  frontend.yaml
  python-cronjob.yaml

mern-project/
  client/
    Dockerfile
    src/
    public/

  server/
    Dockerfile
    routes/
    db/

python-project/
  Dockerfile
  requirements.txt
  ETL.py

terraform/
  main.tf
  variables.tf
  outputs.tf
  README.md

screenshots/

docker-compose.yml
README.md
.gitignore
```

---

## Cloud Ortamı

Cloud provider olarak AWS kullandım.

```text
Cloud Provider: AWS
Region: eu-north-1
Instance Type: c7i-flex.large
Operating System: Ubuntu Server
Kubernetes: k3s
```

Uygulamaya erişim için kullanılan adresler:

```text
Frontend:
http://51.20.77.176:30080

Backend Healthcheck:
http://51.20.77.176:30505/healthcheck

Backend Records Endpoint:
http://51.20.77.176:30505/record

Grafana:
http://51.20.77.176:30300

Prometheus:
http://51.20.77.176:30090
```

Not: EC2 instance stop/start yapılırsa Public IP değişebilir. Böyle bir durumda README, frontend API URL ve GitHub Actions secret içindeki EC2_HOST değeri güncellenmelidir.

---

## Docker Çalışması

MERN uygulamasındaki frontend ve backend için ayrı Dockerfile hazırladım.

Dockerfile dosyaları:

```text
mern-project/client/Dockerfile
mern-project/server/Dockerfile
python-project/Dockerfile
```

Frontend, backend ve Python ETL uygulaması ayrı ayrı image olarak build ediliyor.

MongoDB için Kubernetes tarafında container olarak MongoDB image kullanıldı.

---

## Local Docker Compose

Projeyi lokal ortamda test edebilmek için `docker-compose.yml` dosyası hazırladım.

Çalıştırmak için:

```bash
docker-compose up --build
```

Bu komut ile lokal ortamda şu servisler ayağa kalkar:

```text
MongoDB
Backend
Frontend
```

Bu adımı, uygulamanın container olarak düzgün çalıştığını test etmek için kullandım.

---

## Kubernetes Deployment

Kubernetes manifest dosyalarını `k8s/` klasörü altında tuttum.

Kullandığım Kubernetes dosyaları:

```text
k8s/namespace.yaml
k8s/mongodb.yaml
k8s/backend.yaml
k8s/frontend.yaml
k8s/python-cronjob.yaml
```

Deployment için kullanılan temel komutlar:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mongodb.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/python-cronjob.yaml
```

Pod kontrolü:

```bash
kubectl get pods -n devops-case
```

Servis kontrolü:

```bash
kubectl get svc -n devops-case
```

Beklenen servisler:

```text
frontend   NodePort   30080
backend    NodePort   30505
mongodb    ClusterIP
```

MongoDB servisini dışarıya açmadım. Sadece Kubernetes cluster içinden erişilebilir durumda bıraktım. Backend, MongoDB’ye Kubernetes service adı üzerinden bağlanıyor.

Backend MongoDB bağlantısı:

```text
mongodb://mongodb:27017
```

---

## MERN Uygulaması

Verilen MERN uygulaması kayıt yönetim uygulamasıdır.

Uygulamada kişi kayıtları tutuluyor.

Kayıt alanları:

```text
name
position
level
```

Backend tarafındaki temel endpointler:

```text
GET     /healthcheck
GET     /record
GET     /record/:id
POST    /record
PATCH   /record/:id
DELETE  /record/:id
```

Frontend üzerinden kayıt oluşturma, listeleme, güncelleme ve silme işlemleri yapılabiliyor.

Cloud ortamında frontend ilk başta backend’e `localhost:5050` üzerinden gitmeye çalışıyordu. Lokal ortamda bu çalışsa da cloud ortamında çalışmadı. Çünkü browser açısından `localhost`, AWS sunucusu değil kullanıcının kendi bilgisayarı anlamına gelir.

Bu yüzden frontend API adresini AWS EC2 public IP ve backend NodePort olacak şekilde güncelledim:

```text
http://51.20.77.176:30505
```

---

## Python ETL CronJob

Case içinde Python projesi için şu kriter vardı:

```text
ETL.py file should run every 1 hour
```

Bunu Kubernetes CronJob ile yaptım.

CronJob dosyası:

```text
k8s/python-cronjob.yaml
```

Schedule değeri:

```text
0 * * * *
```

Bu ifade, Python ETL scriptinin her saat başı çalışması anlamına gelir.

Kontrol etmek için:

```bash
kubectl get cronjob -n devops-case
```

Job geçmişini görmek için:

```bash
kubectl get jobs -n devops-case
```

Python ETL pod loglarını görmek için:

```bash
kubectl get pods -n devops-case | grep python
kubectl logs -n devops-case POD_NAME
```

ETL.py çalıştığında GitHub API’ye HTTP GET isteği atıyor ve dönen JSON cevabını stdout’a yazıyor. Bu çıktı Kubernetes pod logları üzerinden görülebiliyor.

---

## CI/CD Pipeline

CI/CD için GitHub Actions kullandım.

Workflow dosyası:

```text
.github/workflows/ci-cd.yml
```

Pipeline genel olarak şu işleri yapıyor:

```text
1. Repository kodunu alıyor
2. Backend bağımlılıklarını kuruyor
3. Backend Docker image build ediyor
4. Frontend bağımlılıklarını kuruyor
5. Frontend build alıyor
6. Frontend Docker image build ediyor
7. Python ETL Docker image build ediyor
8. Image dosyalarını devops-images.tar olarak paketliyor
9. Paketi AWS EC2 sunucusuna SCP ile kopyalıyor
10. k3s container runtime içine image import ediyor
11. Kubernetes manifestlerini apply ediyor
12. Deploymentları güncelliyor
```

GitHub Actions için kullanılan secrets:

```text
EC2_HOST
EC2_USER
EC2_SSH_KEY
```

Private key veya sunucu bağlantı bilgilerini repo içine koymadım. Bunları GitHub Secrets üzerinden kullandım.

---

## Monitoring ve Alerting

Monitoring için Prometheus ve Grafana kurdum.

Monitoring namespace:

```text
monitoring
```

Kurulan temel bileşenler:

```text
Prometheus Server
Grafana
kube-state-metrics
node-exporter
```

Prometheus, Kubernetes metriklerini topluyor. Grafana da Prometheus datasource olarak eklenmiş durumda.

Grafana üzerinde Telegram contact point oluşturdum. Kritik olay olduğunda Telegram üzerinden bildirim gönderecek şekilde ayarladım.

Örnek pod status alert sorgusu:

```promql
sum by (pod, phase) (
  kube_pod_status_phase{namespace="devops-case", phase=~"Pending|Failed|Unknown"} == 1
)
```

Bu alert şunu kontrol ediyor:

```text
devops-case namespace içinde herhangi bir pod Pending, Failed veya Unknown durumuna düşerse alert üret.
```

Telegram contact point ile bu alert Telegram’a bildirim olarak gidiyor.

---

## Logging

Bu case kapsamında logları Kubernetes pod logları üzerinden takip ettim.

Backend logları:

```bash
kubectl logs -n devops-case deployment/backend
```

Frontend logları:

```bash
kubectl logs -n devops-case deployment/frontend
```

MongoDB logları:

```bash
kubectl logs -n devops-case deployment/mongodb
```

Python ETL logları:

```bash
kubectl logs -n devops-case POD_NAME
```

Backend loglarında uygulamanın başladığı ve 5050 portunda dinlediği görülebiliyor.

Python ETL loglarında da scriptin GitHub API’ye istek attığı ve dönen cevabı logladığı görülebiliyor.

Bu projede merkezi log sistemi kurmadım. Loglar Kubernetes native pod logging ile takip ediliyor. Daha büyük production ortamında Loki, ELK veya CloudWatch Logs gibi merkezi loglama çözümleri eklenebilir.

---

## Terraform / Infrastructure as Code

Case içinde bulut kaynakları için Infrastructure as Code isteniyordu. Bunun için Terraform dosyalarını ekledim.

Terraform klasörü:

```text
terraform/
  main.tf
  variables.tf
  outputs.tf
  README.md
```

Terraform ile tanımlanan kaynaklar:

```text
AWS EC2 instance
Security Group
SSH inbound rule
Frontend NodePort inbound rule
Backend NodePort inbound rule
Grafana inbound rule
Prometheus inbound rule
20 GB gp3 disk
```

Terraform dosyalarının syntax kontrolünü yaptım:

```bash
terraform init
terraform validate
```

Sonuç:

```text
Success! The configuration is valid.
```

Bu Terraform dosyaları mevcut çalışan sunucuyu değiştirmek için değil, aynı altyapının kod olarak tekrar oluşturulabilir halini göstermek için eklendi.

---

## Güvenlik Notları

Bu projede dikkat ettiğim güvenlik noktaları:

```text
MongoDB dışarıya açılmadı.
Private key repo içine eklenmedi.
.env dosyaları repo içine eklenmedi.
GitHub Actions secrets kullanıldı.
node_modules repo içine eklenmedi.
devops-images.tar repo içine eklenmedi.
.terraform/ ve tfstate dosyaları repo içine eklenmedi.
```

Demo ortamı olduğu için bazı portlar dışarıya açık bırakıldı:

```text
30080 - Frontend
30505 - Backend
30300 - Grafana
30090 - Prometheus
```

Production ortamında Grafana ve Prometheus doğrudan internete açık bırakılmamalıdır. VPN, Ingress, authentication, HTTPS veya private network arkasında konumlandırılması daha doğru olur.

SSH portu için de production ortamında sadece güvenilir IP adreslerine izin verilmelidir.

---

## Karşılaştığım Sorunlar ve Çözümler

### Frontend localhost problemi

Frontend ilk başta backend API’ye şu adres üzerinden gitmeye çalışıyordu:

```text
http://localhost:5050
```

Bu lokal ortamda çalışıyordu ama AWS üzerinde çalışmadı. Çünkü browser tarafında localhost kullanıcının kendi bilgisayarını gösterir.

Çözüm olarak frontend API adresini şu şekilde güncelledim:

```text
http://51.20.77.176:30505
```

---

### k3s image import problemi

k3s, Docker yerine containerd kullandığı için image’ları direkt Docker daemon üzerinden göremedi.

Bu yüzden GitHub Actions içinde image’ları tar dosyası olarak paketledim ve EC2’ye gönderdim.

Sonra k3s container runtime içine import ettim:

```bash
sudo k3s ctr -n k8s.io images import devops-images.tar
```

---

### EC2 IP değişmesi

EC2 instance stop/start yapılınca Public IP değişti.

Yeni IP:

```text
51.20.77.176
```

IP değişince şu alanların güncellenmesi gerekti:

```text
GitHub Actions EC2_HOST secret
Frontend API URL
README içindeki URL bilgileri

```

---

### Kaynak yetersizliği

Monitoring tarafında Prometheus ve Grafana çalıştı. Loki ile log bazlı alerting eklemeyi de düşündüm. Ancak demo sunucusundaki kaynaklar sınırlı olduğu için Loki/Alloy eklemedim.

Bu yüzden logları Kubernetes pod logs üzerinden takip ettim. Alerting tarafında ise Prometheus/Grafana ile pod status ve kritik Kubernetes durumlarını izledim.

---

## Acceptance Criteria

### MERN Stack Project

| Requirement | Status |
|---|---|
| MongoDB should be connected | Completed |
| All endpoints should work | Completed |
| All pages should work | Completed |

### Python Project

| Requirement | Status |
|---|---|
| ETL.py should run every 1 hour | Completed |

---

## Ekran Görüntüleri

Deployment sonrası alınan ekran görüntüleri `screenshots/` klasörü altında tutulacaktır.



---

## Son Durum

Bu case kapsamında verilen MERN uygulamasını ve Python ETL projesini AWS EC2 üzerindeki k3s Kubernetes ortamına deploy ettim.

Tamamlanan ana başlıklar:

```text
Dockerfile hazırlığı
Docker Compose lokal test
Kubernetes manifestleri
AWS EC2 cloud deployment
Python ETL CronJob
GitHub Actions CI/CD
Prometheus ve Grafana monitoring
Telegram alerting
Terraform IaC dosyaları
README dokümantasyonu
```

Proje şu an cloud ortamında çalışır durumdadır.