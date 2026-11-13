# Show proxy settings
function proxy_show(){
   env | grep -e _PROXY -e _proxy | sort
}
