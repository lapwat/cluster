# Usage

```sh
export VPS_IP=X.X.X.X
curl -L https://raw.githubusercontent.com/lapwat/cluster/main/setup.sh | sh -s $VPS_IP

source $HOME/.bash_aliases
k create --edit -f https://raw.githubusercontent.com/lapwat/cluster/main/letsencrypt-issuer.yaml
k apply -f https://raw.githubusercontent.com/lapwat/cluster/main/hello-service.yaml
```