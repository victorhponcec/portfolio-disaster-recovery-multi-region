# Proyecto: Arquitectura Multi-Región de Alta Disponibilidad y Recuperación ante Desastres (Warm Standby)
**Autor:** Victor Ponce | **Contacto:** [Linkedin](https://www.linkedin.com/in/victorhugoponce) | **Website:** [victorponce.com](https://victorponce.com)

**English Version:** [README.md](https://github.com/victorhponcec/portfolio-disaster-recovery-multi-region/blob/main/README.md)

---

## 1. Descripción General

Este proyecto presenta una **arquitectura multi-región, altamente disponible, con enfoque Warm Standby en AWS**, completamente automatizada con Terraform.  
El objetivo es ofrecer un diseño de **recuperación ante desastres (DR) de nivel productivo**, asegurando la continuidad de la aplicación incluso ante una caída completa de una región **([cough cough](https://dev.to/franciscojeg78/caida-de-aws-en-us-east-1-explicacion-detallada-y-sencilla-1gpb))**.

La solución utiliza **Región A (Primaria)** y **Región B (Standby)** con infraestructura sincronizada, replicación cross-region, failover de origen en CloudFront y resiliencia de datos multi-región.

---

## 2. Diagrama de Arquitectura

<div align="center">

<img src="README/diagram-DR-HA-v3.png" width="700">

**(img. 1 – Arquitectura Multi-Región Warm Standby)**

</div>

---

## 3. Resumen de la Infraestructura

La infraestructura se despliega en **dos regiones de AWS** para soportar Warm Standby:

- **Región A (Primaria):** Maneja el 100% del tráfico de producción  
- **Región B (Standby):** Ejecuta una copia reducida de la infraestructura, lista para escalar durante el failover  
- El failover se realiza automáticamente en el **edge (CloudFront)** y de forma manual/automática en la **capa de base de datos** (también es posible automatizarlo si usamos Aurora, aunque con un costo mayor que la solución con RDS que propongo)
- Pueden revisar la arquitectura de 3 capas en detalle en mi otro proyecto: [Asegurando una Arquitectura de 3 Capas](https://github.com/victorhponcec/portfolio-aws-security-1/blob/main/README.es.md)

### Componentes principales:

### **Capa Global (Edge)**
- Amazon CloudFront  
- AWS WAF  
- Certificados ACM globales  
- Failover de origen hacia ALBs regionales (Primario a Standby)

### **Infraestructura Regional**

Cada región contiene:
<div align="center">

| Capa         | Subnets / AZs                         | Recursos                                                                 | Propósito |
|--------------|----------------------------------------|---------------------------------------------------------------------------|-----------|
| **Web**      | Subnets Públicas A/B                   | ALB público, Auto Scaling Group (tamaño reducido en standby)             | Entrada desde CloudFront |
| **App**      | Subnets Privadas A/B                   | ALB interno, Auto Scaling Group                                          | Lógica de negocio |
| **Base de Datos** | Subnets Privadas C/D              | RDS Multi-AZ (Primaria), Read Replica cross-region (Standby)             | Persistencia de datos |
| **Endpoints** | Subnets Privadas                      | SSM, Secrets Manager, S3 VPC Endpoints                                   | Comunicaciones privadas con AWS |


**(Tabla 1 – Componentes de Infraestructura)**
</div>

---

## 4. Enrutamiento Global y Flujo de Tráfico

### **4.1 Failover de CloudFront**

CloudFront actúa como punto de acceso global y utiliza:

- **Origen Primario:** ALB (Web Tier) en la Región A  
- **Origen de Failover:** ALB (Web Tier) en la Región B  
- **Health checks automáticos**

Con esta integración, no es necesario usar Route 53 para failover activo/pasivo del tráfico web, ya que CloudFront lo maneja a nivel global.

### **Flujo de tráfico**

Los usuarios acceden mediante un dominio en Route 53, que dirige el tráfico a CloudFront.  
CloudFront sirve contenido en caché y envía solicitudes dinámicas al ALB primario (Región A).

Si la Región A deja de estar disponible, CloudFront ejecuta failover automáticamente y enruta el tráfico al ALB de la Región B.

---

## 5. Estrategia Multi-Región de Datos

Existen varias estrategias de DR en AWS ([Disaster recovery options in the cloud](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html)).  
Opté por **Warm Standby**, que mantiene una versión reducida pero funcional del hambiente, capaz de manejar tráfico de inmediato tras el failover, ofreciendo un bajo RPO y RTO.

<div align="center">

<img src="README/disaster-recovery-strategies.png" width="700">

**(img. 2 – Estrategia de Recuperación de Desastres)**

</div>

Para soportar esta configuración Warm Standby, los datos deben estar disponibles en ambas regiones.

### **5.1 RDS Multi-Región**

- Región Primaria: **RDS Multi-AZ** (AZ1 + AZ2)  
- Región Secundaria: **Read Replica Cross-Region** (también Multi-AZ)

Durante un DR:
1. Se promueve la réplica en la región secundaria (puede automatizarse con Aurora)  
2. El la capa App se reconecta localmente  

### **5.2 S3 Multi-Region Access Point (MRAP)**

S3 MRAP provee acceso multi-región con dos buckets (uno por región) en replicación automática, con:

- Failover automático  
- Routing basado en latencia  
- Un único namespace global

---

## 6. Seguridad de Red

Se implementó seguridad de red básica ya que el enfoque principal es HA y DR.  
Para una arquitectura más avanzada de seguridad, pueden revisar mi otro proyecto:  
[Arquitectura de Red Segura Multi-VPC con Transit Gateway y VPN On-Prem](https://github.com/victorhponcec/portfolio-network-security/blob/main/README.es.md)

Ambas regiones replican la misma postura de seguridad:

### **AWS WAF**
- Un conjunto de reglas comunes  
- Protección contra SQL Injection  
- IP reputation blacklist  
- Rate limiting contra DDoS  

### **Security Groups**
- El Application Load Balancer envía tráfico HTTP/HTTPS al Web Tier  
- El Web Tier se comunica con el App Tier  
- El App Tier se conecta a RDS  
- El acceso SSH está restringido y solo permitido mediante la instancia Break-Glass  
- CloudFront reenvía tráfico al ALB usando la prefix list administrada por AWS

### **VPC Endpoints**
- **SSM**  
- **Secrets Manager**  
- **S3**  
Esto asegura que el tráfico hacia estos servicios nunca salga a internet.

### **Aislamiento de Red**
- Sin acceso público a EC2 ni RDS  
- Subnets públicas solo para ALBs y NAT Gateways  
- App y DB completamente privados  

---

## 7. Identidad y Control de Acceso

### **IAM Roles**
- **EC2 SSM Role:** Acceso mediante Session Manager  
- **App Role:** Permisos para SSM + Secrets Manager  
- **RDS Replication Roles:** Replicación cross-region  

### **Gestión de Secrets**
- Credenciales de RDS almacenadas en Secrets Manager  
- El App Tier las obtiene automáticamente  
- Los VPC Endpoints permiten obtenerlos de forma privada  

---

## 8. Confiabilidad

La arquitectura implementa múltiples niveles de resiliencia:

### **Dentro de una Región**
- ALBs Multi-AZ  
- Auto Scaling Multi-AZ  
- RDS Multi-AZ  

### **Entre Regiones**
- Failover de CloudFront  
- Réplica cross-region de RDS  
- S3 MRAP  
- WAF/ACM/CloudFront multi-región  
- Infra idéntica manejada con Terraform  

---

## 9. Proceso de Failover (Warm Standby)

### **Failover Automático**
- CloudFront detecta el ALB primario como no saludable  
- Todo el tráfico se redirige al ALB secundario  

### **Pasos Manuales para la Promoción Completa**
1. Promover la Read Replica de RDS en la región secundaria  

---

## 10. Conclusión

Este proyecto demuestra una **arquitectura multi-región resiliente alineada con estándares empresariales de DR**, utilizando servicios globales de AWS, replicación multi-región y automatización con Terraform.

Garantiza:

- **Alta Disponibilidad (Multi-AZ)**  
- **Recuperación ante Desastres (Warm Standby Multi-Región)**  
- **RTO rápido gracias a CloudFront + replicación**  
- **Seguridad robusta con comunicaciones privadas**

Es una arquitectura escalable, segura y lista para producción.

---

## 13. Mejoras Futuras

- Automatizar la promoción de RDS + actualización de secrets mediante Lambda  
- Integrar Aurora  

---

## Comentarios

Como se mencionó anteriormente, este proyecto se centra en HA y DR.  
Si desean profundizar más sobre implementaciones de seguridad en AWS, pueden revisar mis otros proyectos:

- [Asegurando una Arquitectura de 3 Capas](https://github.com/victorhponcec/portfolio-aws-security-1/blob/main/README.es.md)  
- [Arquitectura de Red Segura Multi-VPC con Transit Gateway y VPN On-Prem](https://github.com/victorhponcec/portfolio-network-security/blob/main/README.es.md)

---
