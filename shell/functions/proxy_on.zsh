# Configure proxy
function proxy_on(){
   # You may need to hardcode your password, proxy server, and proxy port
   # if the following variables do not exist
   export HTTP_PROXY="http://$USERNAME:$PASSWORD@$PROXY_SERVER:$PROXY_PORT"
   export HTTPS_PROXY=$HTTP_PROXY
   export FTP_PROXY=$HTTP_PROXY
   export http_proxy=$HTTP_PROXY
   export https_proxy=$HTTP_PROXY
   export ftp_proxy=$HTTP_PROXY
   # export SOCKS_PROXY=$HTTP_PROXY
   # export no_proxy="localhost,127.0.0.1,$USERDNSDOMAIN"
   export no_proxy="localhost,127.0.0.0/8,::1"

   # Update git and npm to use the proxy
  #  if hash git 2>/dev/null; then
  #    git config --global http.proxy $HTTP_PROXY
  #    git config --global https.proxy $HTTP_PROXY
  #  fi

  #  if hash npm 2>/dev/null; then
  #    npm config set proxy $HTTP_PROXY
  #    npm config set https-proxy $HTTP_PROXY
  #    # npm config set strict-ssl false
  #    # npm config set registry "http://registry.npmjs.org/"
  #  fi

   proxy_show
   echo -e "\nProxy-related environment variables set."

   # clear
}
