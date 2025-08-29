#!/bin/bash
set -e -o pipefail
read -ra arr <<< "$@"
version=${arr[1]}
trap 0 1 2 ERR
# Ensure sudo is installed
apt-get update && apt-get install sudo -
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
bash /tmp/linux-on-ibm-z-scripts/Elasticsearch/${version}/build_elasticsearch.sh -y
# Build deb, rpm, and docker packages
cd elasticsearch
./gradlew :distribution:packages:s390x-deb:assemble -x :libs:entitlement:bridge:compileMain23Java -x :libs:entitlement:compileMain23Java -x :libs:native:compileMain22Java -x :libs:simdvec:compileMain22Java
./gradlew :distribution:packages:s390x-rpm:assemble -x :libs:entitlement:bridge:compileMain23Java -x :libs:entitlement:compileMain23Java -x :libs:native:compileMain22Java -x :libs:simdvec:compileMain22Java
./gradlew :distribution:docker:docker-s390x-export:assemble -x :libs:entitlement:bridge:compileMain23Java -x :libs:entitlement:compileMain23Java -x :libs:native:compileMain22Java -x :libs:simdvec:compileMain22Java
cd ../
cp elasticsearch/distribution/archives/linux-s390x-tar/build/distributions/elasticsearch-${version}-SNAPSHOT-linux-s390x.tar.gz elasticsearch-${version}-linux-s390x.tar.gz
exit 0
