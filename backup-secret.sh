#!/bin/bash

# Direktori untuk menyimpan hasil backup
BACKUP_DIR="$HOME/backup/secret-backup"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Pastikan direktori backup ada
mkdir -p "$BACKUP_DIR"

# Log file
LOG_FILE="$BACKUP_DIR/backup_log_$TIMESTAMP.log"

echo "Backup Secret dimulai pada $(date)" | tee -a "$LOG_FILE"

# Dapatkan semua namespace dan nama Secret
kubectl get secrets --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" | tail -n +2 | while read -r NAMESPACE NAME; do
    echo "Mencadangkan Secret: $NAME dari namespace: $NAMESPACE" | tee -a "$LOG_FILE"

    # Backup setiap secret ke file YAML
    kubectl get secret "$NAME" -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/${NAMESPACE}-${NAME}-$TIMESTAMP.yaml"
    if [ $? -eq 0 ]; then
        echo "Backup sukses: $BACKUP_DIR/${NAMESPACE}-${NAME}-$TIMESTAMP.yaml" | tee -a "$LOG_FILE"
    else
        echo "Backup gagal untuk: $NAME di namespace: $NAMESPACE" | tee -a "$LOG_FILE"
    fi
done

echo "Backup Secret selesai pada $(date)" | tee -a "$LOG_FILE"