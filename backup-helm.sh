
#!/bin/bash

# Direktori untuk menyimpan hasil backup
BACKUP_DIR="$HOME/backup/helm-values-backup"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Pastikan direktori backup ada
mkdir -p "$BACKUP_DIR"

# Log file
LOG_FILE="$BACKUP_DIR/backup_log_$TIMESTAMP.log"

echo "Backup Helm Values dimulai pada $(date)" | tee -a "$LOG_FILE"

# Mendapatkan daftar Helm release di seluruh namespaces beserta namespace-nya
helm list --all-namespaces -o json | jq -r '.[] | "\(.name) \(.namespace)"' | while read -r RELEASE NAMESPACE; do
    echo "Mencadangkan Helm Values untuk release: $RELEASE di namespace: $NAMESPACE" | tee -a "$LOG_FILE"
   
    # Backup values dalam format YAML
    helm get values "$RELEASE" -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/${RELEASE}-values-$NAMESPACE-$TIMESTAMP.yaml"
    if [ $? -eq 0 ]; then
        echo "Backup sukses: $BACKUP_DIR/${RELEASE}-values-$NAMESPACE-$TIMESTAMP.yaml" | tee -a "$LOG_FILE"
    else
        echo "Backup gagal untuk release: $RELEASE di namespace: $NAMESPACE" | tee -a "$LOG_FILE"
    fi
done

echo "Backup Helm Values selesai pada $(date)" | tee -a "$LOG_FILE"

