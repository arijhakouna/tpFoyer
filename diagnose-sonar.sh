#!/bin/bash

echo "=== Diagnostic SonarQube ==="
echo "Date: $(date)"
echo

# Configuration
SONAR_URL="http://10.148.1.146:9000"
JENKINS_URL="http://localhost:8080"

echo "1. Vérification de l'accessibilité de SonarQube..."
if curl -s "$SONAR_URL/api/system/status" > /dev/null; then
    echo "✅ SonarQube est accessible"
    STATUS=$(curl -s "$SONAR_URL/api/system/status" | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
    echo "   Statut: $STATUS"
else
    echo "❌ SonarQube n'est pas accessible"
    exit 1
fi

echo
echo "2. Vérification de l'accessibilité de Jenkins..."
if curl -s "$JENKINS_URL/api/json" > /dev/null; then
    echo "✅ Jenkins est accessible"
else
    echo "❌ Jenkins n'est pas accessible"
fi

echo
echo "3. Vérification des tâches récentes dans SonarQube..."
echo "   URL: $SONAR_URL/api/ce/activity?component=tp-foyer&ps=5"

echo
echo "4. Vérification de la configuration SonarQube dans Jenkins..."
echo "   Vérifiez dans Jenkins: Manage Jenkins > Configure System > SonarQube servers"

echo
echo "5. Conseils de résolution:"
echo "   - Attendez 2-3 minutes après l'analyse pour que SonarQube traite les résultats"
echo "   - Vérifiez que le projet 'tp-foyer' existe dans SonarQube"
echo "   - Vérifiez les logs SonarQube: docker logs <sonarqube-container>"
echo "   - Redémarrez le pipeline avec le nouveau timeout"

echo
echo "6. Pour forcer une nouvelle analyse:"
echo "   mvn clean verify sonar:sonar -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml" 