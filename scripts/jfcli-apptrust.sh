#!/bin/bash
clear
buildApp=${1:-"DEFAULT"}
export JF_NAME="psazuse" JF_EDGE_NAME="psazeuwedge" JFROG_CLI_LOG_LEVEL="DEBUG" 
export JF_RT_URL="https://${JF_NAME}.jfrog.io" PROJECT_KEY="spring-petclinic-ms" 

export TIMESTAMP="$(date '+%Y.%m.%d+%H%M')"
export BUILD_ID="cmd-at.${TIMESTAMP}" APPLICATION_VERSION="${TIMESTAMP}"
export EVD_KEY_PRIVATE="$(cat ~/.ssh/jfrog_evd_private.pem)" EVD_KEY_PUBLIC="$(cat ~/.ssh/jfrog_evd_public.pem)" EVD_KEY_ALIAS="KRISHNAM_JFROG_EVD_PUBLICKEY"

jf config use ${JF_NAME}

common-app-package(){
    local APPLICATION_KEY=${1} 
    local BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-${APPLICATION_KEY}-virtual" 

    printf "\n*** App Package: ${APPLICATION_KEY}  Build and publish **\n"
    jf mvnc --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL}    
    jf mvn clean install -DskipTests -Denforcer.skip -pl spring-petclinic-${APPLICATION_KEY} -am --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --project="${PROJECT_KEY}" --detailed-summary
    jf rt bp ${BUILD_NAME} ${BUILD_ID} --collect-env=true --collect-git-info=true --project="${PROJECT_KEY}" --detailed-summary

    printf "\n*** AppTrust: App Version create **\n"
    export AT_APP_SPEC_JSON="./jfcli-app-spec.json"
    cat > "${AT_APP_SPEC_JSON}" <<EOF
{
  "builds": [
    {
      "name": "${BUILD_NAME}",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    }
  ]
}
EOF

    printf "AppTrust app spec file content: ${AT_APP_SPEC_JSON}"
    cat ${AT_APP_SPEC_JSON}

    # ref: https://docs.jfrog.com/governance/docs/create-application-version-cli 
    # jf apptrust version-create "app-spring-petclinic" 2026.07.23-1225 --spec="./at-app-spec.json" 
    jf apptrust version-create ${APPLICATION_KEY} ${APPLICATION_VERSION} --spec="${AT_APP_SPEC_JSON}" --tag="Package"
    # jf apptrust version-create ${APPLICATION_KEY} ${APPLICATION_VERSION} --source-type-builds="name=${BUILD_NAME}, id=${BUILD_ID}, repository_key" --tag="prototype" --dry-run
    rm -rf ${AT_APP_SPEC_JSON}
}

api-gateway(){
    printf "\n*** API Gateway: Build and publish **\n"
    export APPLICATION_KEY="api-gateway" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-api-gateway-virtual"  # spring-petclinic-ms-api-gateway-init-local, spring-petclinic-ms-api-gateway-dev-local, spring-petclinic-ms-api-gateway-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

config-server(){
    printf "\n*** Config Server: Build and publish **\n"
    export APPLICATION_KEY="config-server" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-config-server-virtual"  # spring-petclinic-ms-config-server-init-local, spring-petclinic-ms-config-server-dev-local, spring-petclinic-ms-config-server-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

customers-service(){
    printf "\n*** Customers Service: Build and publish **\n"
    export APPLICATION_KEY="customers-service" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-customers-service-virtual"  # spring-petclinic-ms-customers-service-init-local, spring-petclinic-ms-customers-service-dev-local, spring-petclinic-ms-customers-service-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

discovery-server(){
    printf "\n*** Discovery Service: Build and publish **\n"
    export APPLICATION_KEY="discovery-server" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-discovery-server-virtual"  # spring-petclinic-ms-discovery-server-init-local, spring-petclinic-ms-discovery-server-dev-local, spring-petclinic-ms-discovery-server-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

genai-service(){
    printf "\n*** GenAI Service: Build and publish **\n"
    export APPLICATION_KEY="genai-service" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-genai-service-virtual"  # spring-petclinic-ms-customers-service-init-local, spring-petclinic-ms-customers-service-dev-local, spring-petclinic-ms-customers-service-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

admin-server(){
    printf "\n*** Admin Service: Build and publish **\n"
    export APPLICATION_KEY="admin-server" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-admin-server-virtual"  # spring-petclinic-ms-customers-service-init-local, spring-petclinic-ms-customers-service-dev-local, spring-petclinic-ms-customers-service-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

vets-service(){
    printf "\n*** Vets Service: Build and publish **\n"
    export APPLICATION_KEY="vets-service" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-vets-service-virtual"  # spring-petclinic-ms-vets-service-init-local, spring-petclinic-ms-vets-service-dev-local, spring-petclinic-ms-vets-service-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

visits-service(){
    printf "\n*** Visits Service: Build and publish **\n"
    export APPLICATION_KEY="visits-service" 
    export BUILD_NAME="${APPLICATION_KEY}" RT_REPO_VIRTUAL="spring-petclinic-ms-visits-service-virtual"  # spring-petclinic-ms-visits-service-init-local, spring-petclinic-ms-visits-service-dev-local, spring-petclinic-ms-visits-service-prod-local,  spring-petclinic-ms-mvn-remote

    common-app-package ${APPLICATION_KEY} 
}

multi-apps-from-app-vc(){
    printf "\n *** ALL Applications to promtoe in ${PROJECT_KEY} from App Version created \n"
    # https://docs.jfrog.com/governance/docs/create-application-version-cli
    export APPLICATION_KEY="all-app-services"
    export ALL_APPS_SPEC_JSON="./jfcli-all-apps-from-vc-spec.json"
    cat > "${ALL_APPS_SPEC_JSON}" <<EOF
{
"versions": [
   {
     "application_key": "api-gateway",
     "version": "${APPLICATION_VERSION}"
   },
   {
     "application_key": "config-server",
     "version": "${APPLICATION_VERSION}"
   }, 
   {
     "application_key": "customers-service",
     "version": "${APPLICATION_VERSION}"
   },
   {
     "application_key": "discovery-server",
     "version": "${APPLICATION_VERSION}"
   },
   {
     "application_key": "genai-service",
     "version": "${APPLICATION_VERSION}"
   },
   {
     "application_key": "admin-server",
     "version": "${APPLICATION_VERSION}"
   },
   {
     "application_key": "vets-service",
     "version": "${APPLICATION_VERSION}"
   },
   {
     "application_key": "visits-service",
     "version": "${APPLICATION_VERSION}"
   }
   ]
}
EOF
    echo "AppTrust ALL APPS spec file content: ${ALL_APPS_SPEC_JSON}"
    cat ${ALL_APPS_SPEC_JSON}

    # ref: https://docs.jfrog.com/governance/docs/create-application-version-cli
    jf apptrust version-create ${APPLICATION_KEY} ${APPLICATION_VERSION} --spec="${ALL_APPS_SPEC_JSON}" --tag="Package"

    #rm -rf ${ALL_APPS_SPEC_JSON}
}
multi-apps-from-builds(){
    printf "\n *** ALL Applications to promtoe in ${PROJECT_KEY} from Builds \n"
    # https://docs.jfrog.com/governance/docs/create-application-version-cli
    export APPLICATION_KEY="all-app-services"
    export ALL_APPS_SPEC_JSON="./jfcli-all-apps-from-builds-spec.json"
    cat > "${ALL_APPS_SPEC_JSON}" <<EOF
{
  "builds": [
    {
      "name": "api-gateway",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "config-server",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "customers-service",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "discovery-server",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "genai-service",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "admin-server",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "vets-service",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    },{
      "name": "visits-service",
      "number": "${BUILD_ID}",
      "repository_key": "${PROJECT_KEY}-build-info",
      "include_dependencies": false
    }
  ]
}
EOF

    echo "AppTrust ALL APPS spec file content: ${ALL_APPS_SPEC_JSON}"
    cat ${AT_APP_ALL_APPS_SPEC_JSONSPEC_JSON}

    # ref: https://docs.jfrog.com/governance/docs/create-application-version-cli 
    jf apptrust version-create ${APPLICATION_KEY} ${APPLICATION_VERSION} --spec="${ALL_APPS_SPEC_JSON}" --tag="Package"


    #rm -rf ${ALL_APPS_SPEC_JSON}
}

rbv2-all-ms(){
   printf "\n *** RLM: Create RBv2 for the project ${PROJECT_KEY} \n"
   export RBv2_SIGNING_KEY="krishnam"
   export RBv2_BUNDLE_NAME="all-ms-apps"
   export RBv2_SPEC_JSON="./jfcli-rbv2-spec.json"
    cat > "${RBv2_SPEC_JSON}" <<EOF
{ 
  "files": [ 
    {"build": "api-gateway/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"}, 
    {"build": "config-server/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"}, 
    {"build": "customers-service/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"}, 
    {"build": "discovery-server/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"}, 
    {"build": "genai-service/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"}, 
    {"build": "admin-server/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"}, 
    {"build": "vets-service/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"},
    {"build": "visits-service/${BUILD_ID}", "includeDeps":"false", "project":"${PROJECT_KEY}"} 
    ] 
}  
EOF
   cat ${RBv2_SPEC_JSON}
   # ref: https://docs.jfrog.com/governance/docs/release-lifecycle-management-cli#create-a-release-bundle-v2
   jf rbc ${RBv2_BUNDLE_NAME} ${BUILD_ID} --sync=true --signing-key=${RBV2_SIGNING_KEY} --spec=${RBv2_SPEC_JSON} --project=${PROJECT_KEY}

   printf "\n *** RBv2: ${RBv2_BUNDLE_NAME} created for the project ${PROJECT_KEY}  ID: ${BUILD_ID} \n"
   sleep 2

   jf rbp ${RBv2_BUNDLE_NAME} ${BUILD_ID} DEV --sync=true --signing-key="${RBv2_SIGNING_KEY}" --project=${PROJECT_KEY}


   # rm -rf ${RBv2_SPEC_JSON}
}

default(){
   api-gateway
   config-server
   customers-service
   discovery-server
   genai-service
   admin-server
   vets-service
   visits-service

   printf "\n *** All applications built and published *** \n"
   printf "\n***** [START] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"
   # multi-apps-from-builds
   multi-apps-from-app-vc
#    rbv2-all-ms
   printf "\n ----------------------------------------------------------------  "
   printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"
}

arg_len=${#buildApp}
buildApp=$(printf "${buildApp}" | tr '[:lower:]' '[:upper:]' | xargs)
printf "User Action: ${buildApp}, and arg length: ${arg_len}"

case ${buildApp} in
    DEFAULT)
        default
        ;;
    API-GATEWAY | API | GATEWAY)
        api-gateway
        ;;
    CONFIG-SERVER | CONFIG)
        config-server
        ;;
    CUSTOMERS-SERVICE | CUSTOMERS)
        customers-service
        ;;
    DISCOVERY-SERVER | DISCOVERY)
        discovery-server
        ;;
    GENAI-SERVICE | GENAI)
        genai-service
        ;;
    ADMIN-SERVER | ADMIN)
        admin-server
        ;;
    VETS-SERVICE | VETS)
        vets-service
        ;;
    VISITS-SERVICE | VISITS)
        visits-service
        ;;
    MULTI-APPS | VCS | MULTI-VC)
        multi-apps-from-app-vc
        ;;
    MULTI-APPS-FROM-BUILDS | BUILDS | MULTI-BUILDS)
        multi-apps-from-builds
        ;;
    RBV2-ALL-MS | RBV2)
        rbv2-all-ms
        ;;
    *)
        printf "Invalid argument: ${buildApp}"
        exit 1
        ;;
esac

printf "\n ----------------------------------------------------------------  "
printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"