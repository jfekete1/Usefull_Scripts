if [[ $# -lt 1 ]]; then 
      echo "Usage: $0 <agent>"; 
      exit 0; 
fi
ep=`echo $1 | awk '{print $0":06"}' | sed 's/:.*/:06/'`
echo Fixing NT agent using $ep
try32bit=0;
tacmd getfile -m $ep -s 'C:\IBM\ITM\TMAITM6_x64\kntenv' -d kntenv.$ep -t text -f
if ! [[ -f kntenv.$ep ]];then 
  try32bit=1;
  tacmd getfile -m $ep -s 'C:\IBM\ITM\TMAITM6\kntenv' -d kntenv.$ep -t text -f
fi

if ! [[ -f kntenv.$ep ]];then
   echo  "Could not download kntenv";
   exit 0;
fi
ENVFILE=kntenv.$ep
cat $ENVFILE | grep "^PATH=" | \
  sed  's/\([^;]*ITM[^;]*\)/|\1|/g' | \
  sed  's/\([^;]*GSK[^;]*\)/|\1|/g' | \
  sed  's/\([^;]*Windows[^;]*\)/|\1|/g' | \
  sed  's/\([^;]*PSTools[^;]*\)/|\1|/g' | \
  sed 's/;[^|][^;|]*//g'  | sed 's/|//g' > path.tmp.$$

#cat $ENVFILE | sed 's/^PATH=/* PATH=/' > $ENVFILE.fix
cat $ENVFILE | grep -v "^PATH=" > $ENVFILE.fix

cat path.tmp.$$ >> $ENVFILE.fix
cat $ENVFILE | grep "^PATH!=" >> $ENVFILE.fix
rm path.tmp.$$ >/dev/null 2>&1





if [[ $try32bit -eq 0 ]]; then
  tacmd putfile -m $ep -s kntenv.$ep.fix -d 'C:\IBM\ITM\TMAITM6_x64\kntenv' -t text -f
else
  tacmd putfile -m $ep -s kntenv.$ep.fix -d 'C:\IBM\ITM\TMAITM6\kntenv' -t text -f
fi

tacmd executecommand -m $ep -o -e -r -v -c 'net start kntcma_primary'
host=`echo $1 | sed 's/:.*//'`
echo tacmd listsystems | grep $host
