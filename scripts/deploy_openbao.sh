#!/bin/bash

# --- Démarrer le conteneur OpenBao ---
# Note: Cette commande utilise l'image 'hashicorp/vault' et un token root prédéfini 'myroottoken'.
# Si vous avez utilisé l'image 'openbao/openbao-dev', le token est généré et doit être récupéré des logs.
echo "Démarrage du conteneur OpenBao..."
sudo docker run --cap-add=IPC_LOCK -d \
-e 'BAO_DEV_ROOT_TOKEN_ID=myroottoken' \
-p 8200:8200 \
--name openbao \
hashicorp/vault server -dev -dev-listen-address='0.0.0.0:8200'

# --- Vérifier le statut et récupérer le Root Token ---
# Si vous avez utilisé 'BAO_DEV_ROOT_TOKEN_ID=myroottoken', votre token est 'myroottoken'.
# Sinon, récupérez le Root Token généré dans les logs (ex: hvs.S4bIugyJKMX5YYJZRV6lI4I4).
echo "Récupération du token root..."
sudo docker logs openbao
# >> Récupérer le Root Token généré (ex: hvs.S4bIugyJKMX5YYJZRV6lI4I4)

# --- Configurer votre terminal pour communiquer avec OpenBao ---
echo "onfiguration de l'environnement..."
export BAO_ADDR='http://127.0.0.1:8200'
export BAO_TOKEN='<your-root-token>' # <<< REMPLACEZ PAR VOTRE TOKEN ROOT RÉEL >>>
echo "BAO_ADDR et BAO_TOKEN sont configurés."

# --- Activer le moteur de secrets Key/Value (KV) ---
echo ""Activation du moteur de secrets KV..."
# Cette commande active le stockage de secrets KV dans OpenBao.
sudo docker exec -e VAULT_ADDR='http://127.0.0.1:8200' -e VAULT_TOKEN='<your-root-token>' openbao vault secrets enable kv

# --- Créer les variables d'environnement pour les identifiants Azure ---
echo "Préparation des identifiants Azure..."
# (Assurez-vous que ce sont les bonnes valeurs pour votre Service Principal)
export ARM_CLIENT_ID="<your-arm-client-id>"
export ARM_CLIENT_SECRET="<your-arm-client-secret>" # <<< REMPLACEZ PAR VOTRE SECRET CLIENT VALIDE >>>
export ARM_TENANT_ID="<your-arm-tenant-id>"
export ARM_SUBSCRIPTION_ID="<your-arm-subscription-id>"
echo "Variables ARM_* configurées."

# --- Stocker les identifiants Azure dans OpenBao ---
echo "Stockage des identifiants Azure dans OpenBao..."
sudo docker exec \
 -e VAULT_ADDR='http://127.0.0.1:8200' \
 -e VAULT_TOKEN='<your-root-token>' \
 openbao \
 vault kv put kv/starfleet/dev/azure_spn \
 client_id="$ARM_CLIENT_ID" \
 client_secret="$ARM_CLIENT_SECRET" \
 tenant_id="$ARM_TENANT_ID" \
 subscription_id="$ARM_SUBSCRIPTION_ID"
echo "Identifiants Azure stockés dans OpenBao."

# --- Vérifier que les secrets sont bien stockés dans OpenBao ---
echo "Vérification des secrets stockés..."
sudo docker exec \
-e VAULT_ADDR='http://127.0.0.1:8200' \
-e VAULT_TOKEN='<your-root-token>' \
openbao \
vault kv get kv/starfleet/dev/azure_spn
echo "Vérification terminée."

echo "Script deploy_openbao.sh exécuté avec succès."
