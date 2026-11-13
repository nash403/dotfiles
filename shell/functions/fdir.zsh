# Find directories whose name contains the argument (case-insensitive)
fdir() { find . -type d -iname "*$1*";}
