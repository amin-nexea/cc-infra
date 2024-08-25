# gcloud compute networks create cc-network --subnet-mode=auto

# gcloud compute firewall-rules create cc-allow-http --network cc-network --allow tcp:80
# gcloud compute firewall-rules create cc-allow-https --network cc-network --allow tcp:443
# gcloud compute firewall-rules create cc-allow-ssh --network cc-network --allow tcp:22

# gcloud compute instances create cc-production \
#     --machine-type=e2-highmem-4 \
#     --zone=us-central1-a \
#     --network=cc-network \
#     --image-family=ubuntu-2004-lts \
#     --image-project=ubuntu-os-cloud \
#     --boot-disk-size=100GB \
#     --boot-disk-type=pd-ssd

# gcloud sql instances create cc-postgres-prod \
# --database-version=POSTGRES_13 \
# --tier=db-custom-2-7680 \
# --region=us-central1

# gcloud sql databases create cult_creative --instance=cc-postgres-prod

# gcloud sql users set-password postgres \
#     --instance=cc-postgres-prod \
#     --password=[YOUR_SECURE_PASSWORD]

# ```bash
# gcloud compute ssh cc-production
# ```

# Update and install Docker and Docker Compose
# sudo apt-get update
# sudo apt-get install -y docker.io docker-compose

# Clone your repository
git clone https://your-repo-url.git
cd your-project-folder

# Create an .env file for environment-specific variables
# nano .env
# Add necessary environment variables

upstream api {
    server cc-backend:3001;
}

upstream client {
    server cc-frontend:3030;
}

server {
    client_max_body_size 500M;
    listen 80;

    location / {
        proxy_pass http://client;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /sockjs-node {
        proxy_pass http://client;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }

    location /api {
        rewrite /api/(.*) /$1 break;
        proxy_pass http://api;
    }

    location /socket.io {
        proxy_pass http://api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_cache_bypass $http_upgrade;
        proxy_redirect off;
    }
}

sudo docker-compose up -d

# Create an instance group
gcloud compute instance-groups unmanaged create cc-prod-group \
    --zone=us-central1-a

gcloud compute instance-groups unmanaged add-instances cc-prod-group \
    --instances=cc-production \
    --zone=us-central1-a

# Create a health check
gcloud compute health-checks create http cc-health-check --port 80

# Create a backend service
gcloud compute backend-services create cc-backend \
    --protocol=HTTP \
    --health-checks=cc-health-check \
    --global

gcloud compute backend-services add-backend cc-backend \
    --instance-group=cc-prod-group \
    --instance-group-zone=us-central1-a \
    --global

# Create a URL map
gcloud compute url-maps create cc-url-map \
    --default-service cc-backend

# Upload your SSL certificate
gcloud compute ssl-certificates create cc-ssl-cert \
    --certificate=/path/to/your/certificate.crt \
    --private-key=/path/to/your/private-key.key

# Create a target HTTPS proxy
gcloud compute target-https-proxies create cc-https-proxy \
    --url-map cc-url-map \
    --ssl-certificates cc-ssl-cert

# Create a global forwarding rule
gcloud compute forwarding-rules create cc-https-forwarding-rule \
    --global \
    --target-https-proxy cc-https-proxy \
    --ports 443

gcloud compute forwarding-rules describe cc-https-forwarding-rule \
--global \
--format="get(IPAddress)"
