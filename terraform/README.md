# Terraform Altyapı Dosyaları

Bu klasör, DevOps case projesinde kullanılan AWS altyapısını Terraform ile tanımlamak için hazırlanmıştır.

Terraform dosyaları, AWS üzerinde aynı altyapının tekrar oluşturulabilir hale gelmesini sağlar. Bu sayede EC2 instance, Security Group ve gerekli inbound port kuralları manuel olarak değil, kod üzerinden yönetilebilir.

## Oluşturulan Kaynaklar

Terraform dosyaları aşağıdaki AWS kaynaklarını tanımlar:

- AWS EC2 instance
- Security Group
- SSH inbound rule
- Frontend NodePort inbound rule
- Backend NodePort inbound rule
- Grafana inbound rule
- Prometheus inbound rule
- 20 GB gp3 root disk

## Makine Bilgileri

Bu case çalışmasında kullanılan EC2 instance bilgileri:

```text
Cloud Provider: AWS
Region: eu-north-1
Instance Type: c7i-flex.large
vCPU: 2
Memory: 4 GiB
Operating System: Ubuntu Server
Root Disk: 20 GB gp3
```

İlk kurulumda daha düşük kaynaklı bir instance kullanılmıştır. Kubernetes, MongoDB, Prometheus, Grafana ve uygulama podları aynı node üzerinde çalıştığı için kaynak ihtiyacı artmıştır. Bu nedenle instance type değeri `c7i-flex.large` olarak güncellenmiştir.

## Kullanım

Terraform komutları aşağıdaki şekilde çalıştırılabilir:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

> Not: `terraform apply` komutu gerçek AWS kaynakları oluşturur. Bu yüzden çalıştırmadan önce maliyet ve kaynak kontrolü yapılmalıdır.

## Değişkenler

| Değişken | Açıklama | Varsayılan Değer |
|---|---|---|
| aws_region | AWS region bilgisi | eu-north-1 |
| instance_type | EC2 instance tipi | c7i-flex.large |
| key_name | AWS üzerinde mevcut olan EC2 key pair adı | devops-case-key |
| ssh_allowed_cidr | SSH erişimi için izin verilen CIDR bloğu | 0.0.0.0/0 |
| monitoring_allowed_cidr | Grafana ve Prometheus erişimi için izin verilen CIDR bloğu | 0.0.0.0/0 |

## Outputs

Terraform çalıştırıldığında aşağıdaki bilgileri çıktı olarak verir:

- EC2 public IP adresi
- Frontend URL
- Backend healthcheck URL
- Grafana URL
- Prometheus URL

## Güvenlik Notları

Bu proje demo/case ortamı için hazırlandığı için bazı portlar dışarıya açık bırakılmıştır.

Production ortamında aşağıdaki güvenlik önlemleri uygulanmalıdır:

- SSH erişimi sadece güvenilir IP adresleriyle sınırlandırılmalıdır.
- Grafana ve Prometheus doğrudan internete açık bırakılmamalıdır.
- Secret bilgileri repository içinde tutulmamalıdır.
- HTTPS, Ingress, Load Balancer, VPN veya private network kullanılmalıdır.
- Terraform state dosyaları repository içine eklenmemelidir.