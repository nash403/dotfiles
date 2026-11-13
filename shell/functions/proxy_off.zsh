# Disable proxy settings
function proxy_off(){
   variables=( \
      "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY" \
      "no_proxy" "http_proxy" "https_proxy" "ftp_proxy" \
   )

   for i in "${variables[@]}"
   do
      unset $i
   done

   # Update git and npm to disable the proxy
  #  if hash git 2>/dev/null; then
  #    git config --global --unset http.proxy
  #    git config --global --unset https.proxy
  #  fi

  #  if hash npm 2>/dev/null; then
  #    npm config rm proxy
  #    npm config rm https-proxy
  #    # npm config set strict-ssl false
  #    # npm config set registry "http://registry.npmjs.org/"
  #  fi

   proxy_show
   echo -e "\nProxy-related environment variables removed."
}
