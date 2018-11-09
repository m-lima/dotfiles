# export COMPUTER_SYMBOL='§'
# export COMPUTER_SYMBOL='φ'
# export COMPUTER_SYMBOL='π'
# export COMPUTER_SYMBOL='Њ'
# export COMPUTER_SYMBOL='☧'
# export COMPUTER_SYMBOL='ɳ'
export COMPUTER_SYMBOL='✝'
# export COMPUTER_SYMBOL='#'
# export COMPUTER_SYMBOL='☢'
# export COMPUTER_SYMBOL='ø'
# export COMPUTER_SYMBOL='ƛ'

export DDT_DIR=/Users/lima/code/ddt/dpa-gateway
export DDT_MAIN_DIR=/Users/lima/code/ddt
export DDT_TMP=/Users/lima/code/ddt/tmp
export DDT_INFRA=/Users/lima/code/ddt/infra
export DDT_INFRA_MAIN=/Users/lima/code/ddt/infra/ddyt-infrastructure

plugins+=(ddt aws aws-vault)

export GOPATH=/Users/lima/code/mine/go

alias oni='/Applications/Oni.app/Contents/MacOS/Oni'

### URL encoder
function rawurlencode {
  echo -ne "$1" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'
}

function tonic-purchase {
  curl -k -v -XPOST -H 'Accept-Language: en' -H 'Content-Type: application/json' -d '{ "purchaseRequest":{"planId":"TONICADV129TK40MIND45","transactionId":"2017030606551550096"}}' -H "Authorization: Bearer $token2" http://192.168.99.100:5000/$cpid2/purchasePlan
}

function tonic-cpid {
  curl -H 'X-OPERATOR:GP' -H "MSISDN: 90006401" http://192.168.99.100:6000/cpid/tonic
}

function deployToDevelopment {
  eval $(aws ecr get-login --region eu-central-1 | sed -e 's~-e none~~')
  docker tag 781261959714.dkr.ecr.eu-central-1.amazonaws.com/ddt/"$1":1.7.185-SNAPSHOT 781261959714.dkr.ecr.eu-central-1.amazonaws.com/ddt/"$1":SNAPSHOT
  docker push 781261959714.dkr.ecr.eu-central-1.amazonaws.com/ddt/"$1":SNAPSHOT
  # ./gradlew deployDPAGWToDevelopment -x test
}

function getOauthToken {
  local env="production"

  if [ $1 ]
  then
    env=$1
  fi

  export token=`ddt xdpa -e local -a -q 2>&1 | grep access_token | cut -d ':' -f2 | cut -d '"' -f2`

  # export token=`curl -XPOST -d 'grant_type=client_credentials&scope=cco.dd.yt.data-plan.inquire' -u "telenordigital-dataplanreader-server:$(cat ~/.ps/dpa)" $server 2> /dev/null | cut -d ',' -f 1 | cut -d '"' -f 4`
}

function getCpid {
  if [[ $# -ne 3 ]]
  then
    echo "[31mExpected three parameters. sp operation id[m"
    echo "Usage: $0 sp operator id"
    echo "	sp		Service provider"
    echo "	operator	digi | dtac | gp"
    echo "	id		MSISDN"
    return
  fi

  local sp=$1
  local operator=$2
  local msisdn=$3
  local msisdnHeader

  case $operator in
    dtac) msisdnHeader="X-Nokia-msisdn" ;;
    gp) msisdnHeader="MSISDN" ;;
    digi) msisdnHeader="x-up-calling-line-id" ;;
  esac

  cpid=`curl "http://cpid1.dataplan.telenordigital.com/cpid/$sp" -H "X-OPERATOR: $operator" -H "$msisdnHeader: $msisdn" 2> /dev/null`
  python -m json.tool <<< $cpid
  cpid=`echo $cpid | cut -d ',' -f 1 | cut -d '"' -f 4`
  echo `rawurlencode $cpid`
}

function getDpa {
  if [[ $# -ne 4 ]]
  then
    echo "[31mExpected four parameters[m"
    echo "Usage: $0 sp operation id operator"
    echo "	sp		Service provider"
    echo "	operation	status | upsellOffer | info"
    echo "	id		MSISDN or CPID"
    echo "	operator	tp | dtac | digi | gp"
    return
  fi

  local sp=$1
  local operation=$2
  local id=$3
  local host

  [[ "$operator" == "tp" ]] && host="dpa-de" || host="dpa"


  [ -z $token ] && export token=`getOauthToken`

  curl --header "Authorization: Bearer $token" "https://$host.dataplan.telenordigital.com/$sp/$id/$operation"
  # curl --header "Authorization: Bearer $token" "https://dpa.dataplan.telenordigital.com/$sp/$id/$operation" 2> /dev/null | python -m json.tool
}

function getSweden {
  case $1 in
    1|"") local COMMAND=head ;;
    2) local COMMAND=tail ;;
    *) echo "Unrecognized parameter: "$1 return ;;
  esac

  local pass=`cat ~/.ps/sweden | grep pass | cut -d ' ' -f2 | $COMMAND -1`
  echo $pass
  echo -n $pass | pbcopy
}
