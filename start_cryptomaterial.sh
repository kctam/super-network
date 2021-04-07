mkdir -p /tmp/hyperledger
rm -rf /tmp/hyperledger/*

docker-compose up -d ca-tls rca-org1 rca-org2 rca-org3
sleep 5
sudo chown -R vagrant:vagrant /tmp/hyperledger/*

echo "Working on TLS-CA"

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin

fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052
sleep 5

fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org3 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org1 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org2 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org3 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name admin-org2 --id.secret org2AdminPW --id.type admin -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name admin-org3 --id.secret org3AdminPW --id.type admin -u https://0.0.0.0:7052

echo "Working on RCA-ORG1"

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/ca/admin

fabric-ca-client enroll -d -u https://rca-org1-admin:rca-org1-adminpw@0.0.0.0:7054
sleep 5

fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name orderer1-org1 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u https://0.0.0.0:7054

echo "Working on RCA-ORG2"

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/ca/admin

fabric-ca-client enroll -d -u https://rca-org2-admin:rca-org2-adminpw@0.0.0.0:7055
sleep 5

fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name orderer1-org2 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name admin-org2 --id.secret org2AdminPW --id.type admin -u https://0.0.0.0:7055

echo "Working on RCA-ORG3"

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org3/ca/admin

fabric-ca-client enroll -d -u https://rca-org3-admin:rca-org3-adminpw@0.0.0.0:7056
sleep 5

fabric-ca-client register -d --id.name peer1-org3 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7056
fabric-ca-client register -d --id.name orderer1-org3 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7056
fabric-ca-client register -d --id.name admin-org3 --id.secret org3AdminPW --id.type admin -u https://0.0.0.0:7056

echo "All CA and registration done"

sleep 5

echo "Enroll Org1"

echo "*** Enroll peer1-org1"

mkdir -p /tmp/hyperledger/org1/peer1/assets/ca 
cp /tmp/hyperledger/org1/ca/admin/msp/cacerts/0-0-0-0-7054.pem /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem

mkdir -p /tmp/hyperledger/org1/peer1/assets/tls-ca 
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7054
sleep 5

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org1 --csr.hosts localhost
sleep 5

cp /tmp/hyperledger/org1/peer1/tls-msp/keystore/*_sk /tmp/hyperledger/org1/peer1/tls-msp/keystore/key.pem

echo "### Enroll orderer1-org1"

# preparation
mkdir -p /tmp/hyperledger/org1/orderer1/assets/ca 
cp /tmp/hyperledger/org1/ca/admin/msp/cacerts/0-0-0-0-7054.pem /tmp/hyperledger/org1/orderer1/assets/ca/org1-ca-cert.pem

mkdir -p /tmp/hyperledger/org1/orderer1/assets/tls-ca 
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org1/orderer1/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/orderer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/orderer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://orderer1-org1:ordererpw@0.0.0.0:7054
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/orderer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://orderer1-org1:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org1 --csr.hosts localhost
sleep 5

cp /tmp/hyperledger/org1/orderer1/tls-msp/keystore/*_sk /tmp/hyperledger/org1/orderer1/tls-msp/keystore/key.pem

echo "### Enroll Admin"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7054

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7052 --enrollment.profile tls
sleep 5

cp /tmp/hyperledger/org1/admin/tls-msp/keystore/*_sk /tmp/hyperledger/org1/admin/tls-msp/keystore/key.pem


mkdir -p /tmp/hyperledger/org1/peer1/msp/admincerts
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem

mkdir -p /tmp/hyperledger/org1/admin/msp/admincerts
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/admin/msp/admincerts/org1-admin-cert.pem

mkdir -p /tmp/hyperledger/org1/msp/{admincerts,cacerts,tlscacerts,users}
cp /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem /tmp/hyperledger/org1/msp/cacerts/
cp /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem /tmp/hyperledger/org1/orderer1/msp/cacerts/
cp /tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem /tmp/hyperledger/org1/msp/tlscacerts/
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/msp/admincerts/admin-org1-cert.pem
cp ./org1-config.yaml /tmp/hyperledger/org1/msp/config.yaml
cp ./org1-config.yaml /tmp/hyperledger/org1/orderer1/msp/config.yaml

echo "Enroll Org2"

echo "*** Enroll peer1-org2"

mkdir -p /tmp/hyperledger/org2/peer1/assets/ca 
cp /tmp/hyperledger/org2/ca/admin/msp/cacerts/0-0-0-0-7055.pem /tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem

mkdir -p /tmp/hyperledger/org2/peer1/assets/tls-ca 
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7055
sleep 5

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org2 --csr.hosts localhost
sleep 5

cp /tmp/hyperledger/org2/peer1/tls-msp/keystore/*_sk /tmp/hyperledger/org2/peer1/tls-msp/keystore/key.pem

echo "### Enroll orderer1-org2"

# preparation
mkdir -p /tmp/hyperledger/org2/orderer1/assets/ca 
cp /tmp/hyperledger/org2/ca/admin/msp/cacerts/0-0-0-0-7055.pem /tmp/hyperledger/org2/orderer1/assets/ca/org2-ca-cert.pem

mkdir -p /tmp/hyperledger/org2/orderer1/assets/tls-ca 
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org2/orderer1/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/orderer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/orderer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://orderer1-org2:ordererpw@0.0.0.0:7055
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/orderer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://orderer1-org2:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org2 --csr.hosts localhost
sleep 5

cp /tmp/hyperledger/org2/orderer1/tls-msp/keystore/*_sk /tmp/hyperledger/org2/orderer1/tls-msp/keystore/key.pem

echo "### Enroll Admin"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7055

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7052 --enrollment.profile tls
sleep 5

cp /tmp/hyperledger/org2/admin/tls-msp/keystore/*_sk /tmp/hyperledger/org2/admin/tls-msp/keystore/key.pem

mkdir -p /tmp/hyperledger/org2/peer1/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem

mkdir -p /tmp/hyperledger/org2/admin/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/admin/msp/admincerts/org2-admin-cert.pem

mkdir -p /tmp/hyperledger/org2/msp/{admincerts,cacerts,tlscacerts,users}
cp /tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem /tmp/hyperledger/org2/msp/cacerts/
cp /tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem /tmp/hyperledger/org2/orderer1/msp/cacerts/
cp /tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem /tmp/hyperledger/org2/msp/tlscacerts/
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/msp/admincerts/admin-org2-cert.pem
cp ./org2-config.yaml /tmp/hyperledger/org2/msp/config.yaml
cp ./org2-config.yaml /tmp/hyperledger/org2/orderer1/msp/config.yaml

echo "Enroll Org3"

echo "*** Enroll peer1-org3"

mkdir -p /tmp/hyperledger/org3/peer1/assets/ca
cp /tmp/hyperledger/org3/ca/admin/msp/cacerts/0-0-0-0-7056.pem /tmp/hyperledger/org3/peer1/assets/ca/org3-ca-cert.pem

mkdir -p /tmp/hyperledger/org3/peer1/assets/tls-ca
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org3/peer1/assets/tls-ca/tls-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org3/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/peer1/assets/ca/org3-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://peer1-org3:peer1PW@0.0.0.0:7056
sleep 5

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org3:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org3 --csr.hosts localhost
sleep 5

cp /tmp/hyperledger/org3/peer1/tls-msp/keystore/*_sk /tmp/hyperledger/org3/peer1/tls-msp/keystore/key.pem

echo "### Enroll orderer1-org3"

# preparation
mkdir -p /tmp/hyperledger/org3/orderer1/assets/ca
cp /tmp/hyperledger/org3/ca/admin/msp/cacerts/0-0-0-0-7056.pem /tmp/hyperledger/org3/orderer1/assets/ca/org3-ca-cert.pem

mkdir -p /tmp/hyperledger/org3/orderer1/assets/tls-ca
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org3/orderer1/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org3/orderer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/orderer1/assets/ca/org3-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://orderer1-org3:ordererpw@0.0.0.0:7056
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/orderer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://orderer1-org3:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org3 --csr.hosts localhost
sleep 5

cp /tmp/hyperledger/org3/orderer1/tls-msp/keystore/*_sk /tmp/hyperledger/org3/orderer1/tls-msp/keystore/key.pem

echo "### Enroll Admin"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org3/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/peer1/assets/ca/org3-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://admin-org3:org3AdminPW@0.0.0.0:7056

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org3/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://admin-org3:org3AdminPW@0.0.0.0:7052 --enrollment.profile tls
sleep 5

cp /tmp/hyperledger/org3/admin/tls-msp/keystore/*_sk /tmp/hyperledger/org3/admin/tls-msp/keystore/key.pem

mkdir -p /tmp/hyperledger/org3/peer1/msp/admincerts
cp /tmp/hyperledger/org3/admin/msp/signcerts/cert.pem /tmp/hyperledger/org3/peer1/msp/admincerts/org3-admin-cert.pem

mkdir -p /tmp/hyperledger/org3/admin/msp/admincerts
cp /tmp/hyperledger/org3/admin/msp/signcerts/cert.pem /tmp/hyperledger/org3/admin/msp/admincerts/org3-admin-cert.pem

mkdir -p /tmp/hyperledger/org3/msp/{admincerts,cacerts,tlscacerts,users}
cp /tmp/hyperledger/org3/peer1/assets/ca/org3-ca-cert.pem /tmp/hyperledger/org3/msp/cacerts/
cp /tmp/hyperledger/org3/peer1/assets/ca/org3-ca-cert.pem /tmp/hyperledger/org3/orderer1/msp/cacerts/
cp /tmp/hyperledger/org3/peer1/assets/tls-ca/tls-ca-cert.pem /tmp/hyperledger/org3/msp/tlscacerts/
cp /tmp/hyperledger/org3/admin/msp/signcerts/cert.pem /tmp/hyperledger/org3/msp/admincerts/admin-org3-cert.pem
cp ./org3-config.yaml /tmp/hyperledger/org3/msp/config.yaml
cp ./org3-config.yaml /tmp/hyperledger/org3/orderer1/msp/config.yaml

