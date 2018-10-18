#!/bin/ksh


SCRIPTHOME=/home/huh90029/patch

for zs in `cat $SCRIPTHOME/os_agent.txt`
do
echo $zs
 tacmd listsystems | grep -i $zs | awk '{print$2}' > $SCRIPTHOME/ostype.txt
        if [ `cat $SCRIPTHOME/ostype.txt` == UX ] ; then
         tacmd executecommand -m $zs -o -v -e -r -c '$CANDLEHOME/bin/cinfo -r' | grep CandleHome: | awk -F ": " '{print$2}' > $SCRIPTHOME/candlehome.txt
        sleep 5
         tacmd executecommand -m $zs -o -v -e -r -c '$CANDLEHOME/bin/cinfo -t | grep gs' | grep -v KUIEXC001I | grep -v KUIEXC000I: | grep -v ^0 | awk '{print$6}' > $SCRIPTHOME/axversion.txt

        sleep 5
                for v in `cat $SCRIPTHOME/axversion.txt`
                do
                echo " tacmd executecommand -m $zs -o -v -e -r -c ' `cat $SCRIPTHOME/candlehome.txt`/bin/cinfo -t' | grep -i Installer | grep -v KUIEXC001I | grep -v KUIEXC000I: | grep -v ^0 | awk '{print\$6}' | awk -F : '{print\$2}' > $SCRIPTHOME/agentversion.txt" > $SCRIPTHOME/execommand.txt

                $SCRIPTHOME/execommand.txt
                sleep 5
                        if [ "$v" == aix526 ] ; then
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                echo ""
                                echo "### Send package to the server ###"
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -d `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -f

                                echo ""
                                echo "### Tar package to the Candlehome/config folder ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'cd $CANDLEHOME/config ; /usr/bin/tar -xvf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
                                sleep 5
                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_aix526_tema_8.0.50.88.tar'" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                fi
                        elif [ "$v" == aix523 ] ; then
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                echo ""
                                echo "### Send package to the server ###"
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -d `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -f

                                echo ""
                                echo "### Tar package to the Candlehome/config folder ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'cd $CANDLEHOME/config ; /usr/bin/tar -xvf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
                                sleep 5
                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_aix523_tema_8.0.50.88.tar'" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                fi
                       fi
                done

        echo "### Remove the fix package and folder from the server ###"
         tacmd executecommand -m $zs -o -v -e -r -c 'rm -f $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
        sleep 5
         tacmd executecommand -m $zs -o -v -e -r -c 'rm -Rf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522'
        sleep 5
        echo ""
        echo "### Check the gs version: @06.30.07.00 - IJ04522@ ###"
         tacmd executecommand -m $zs -o -v -e -r -c '$CANDLEHOME/bin/cinfo -i -z'
        sleep 5


        elif [ `cat $SCRIPTHOME/ostype.txt` == LZ ] ; then
         tacmd executecommand -m $zs -o -v -e -r -c 'echo $CANDLEHOME' | grep -v KUIEXC001I | grep -v KUIEXC000I: | grep -v ^0 | grep -v '^$' > $SCRIPTHOME/candlehome.txt
        sleep 5
         tacmd executecommand -m $zs -o -v -e -r -c '$CANDLEHOME/bin/cinfo -t | grep gs' | grep -v KUIEXC001I | grep -v KUIEXC000I: | grep -v ^0 | awk '{print$6}' > $SCRIPTHOME/axversion.txt

       sleep 5
                for v in `cat $SCRIPTHOME/axversion.txt`
                do
                echo " tacmd executecommand -m $zs -o -v -e -r -c ' `cat $SCRIPTHOME/candlehome.txt`/bin/cinfo -t' | grep -i Installer | grep -v KUIEXC001I | grep -v KUIEXC000I: | grep -v ^0 | awk '{print\$6}' | awk -F : '{print\$2}' > $SCRIPTHOME/agentversion.txt" > $SCRIPTHOME/execommand.txt
                $SCRIPTHOME/execommand.txt
                sleep 5
                        if [ "$v" == ls3263 ] ; then
                                echo ""
                                echo "### Send package to the server ###"
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -d `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -f

                                echo ""
                                echo "### Tar package to the Candlehome/config folder ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'cd $CANDLEHOME/config ; /bin/tar -xvf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
                                sleep 5
                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_ls3263_tema_8.0.50.88.tar '" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                fi
                        elif [ "$v" == ls3266 ] ; then
                                echo ""
                                echo "### Send package to the server ###"
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -d `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -f

                                echo ""
                                echo "### Tar package to the Candlehome/config folder ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'cd $CANDLEHOME/config ; /bin/tar -xvf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
                                sleep 5
                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_ls3266_tema_8.0.50.88.tar '" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                fi
                        elif [ "$v" == lx8266 ] ; then
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                echo ""
                                echo "### Send package to the server ###"
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -d `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar -f

                                echo ""
                                echo "### Tar package to the Candlehome/config folder ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'cd $CANDLEHOME/config ; /bin/tar -xvf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
                                sleep 5
                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat $SCRIPTHOME/candlehome.txt`/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_lx8266_tema_8.0.50.88.tar '" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                fi
                        fi
                done

        echo ""
        echo "### Remove the fix package and folder from the server ###"
         tacmd executecommand -m $zs -o -v -e -r -c 'rm -f $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522.tar'
        sleep 5
         tacmd executecommand -m $zs -o -v -e -r -c 'rm -Rf $CANDLEHOME/config/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522'
        sleep 5
        echo ""
        echo "### Check the gs version: @06.30.07.00 - IJ04522@ ###"
         tacmd executecommand -m $zs -o -v -e -r -c '$CANDLEHOME/bin/cinfo -i -z'
        sleep 5


        elif [ `cat $SCRIPTHOME/ostype.txt` == NT ] ; then
         tacmd executecommand -m $zs -o -v -e -r -c 'SET CANDLE_HOME' | grep -v KUIEXC001I | grep -v KUIEXC000I: | grep -v ^0 | grep -v '^$' | awk -F = '{print$2}' > $SCRIPTHOME/candlehome.txt

        sleep 5
         tacmd executecommand -m $zs -o -v -e -r -c 'kincinfo -t' | grep GS | awk '{print$7}' > $SCRIPTHOME/axversion.txt
        sleep 5
                for v in `cat $SCRIPTHOME/axversion.txt`
                do
                echo " tacmd executecommand -m $zs -o -v -e -r -c 'kincinfo -t' | grep -i KNT | awk '{print\$9}' > $SCRIPTHOME/agentversion.txt" > $SCRIPTHOME/execommand.txt

                $SCRIPTHOME/execommand.txt
                sleep 5
                        if [ "$v" == WIX64 ] ; then
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                echo ""
                                echo "### Send files to the server 64 bit ###"
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_wix64_tema_8.0.50.88.cab -d `cat $SCRIPTHOME/candlehome.txt`/Config/kgs_wix64_tema_8.0.50.88.cab -f

                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch.exe -d `cat $SCRIPTHOME/candlehome.txt`/config/itmpatch.exe -f

                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`\Config\itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat \$SCRIPTHOME/candlehome.txt`\Config\kgs_wix64_tema_8.0.50.88.cab'" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                fi
                                echo ""
                                echo "### Remove files from the server ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'del /f %CANDLE_HOME%\Config\kgs_wix64_tema_8.0.50.88.cab'
                                sleep 5
                                 tacmd executecommand -m $zs -o -v -e -r -c 'del /f %CANDLE_HOME%\Config\itmpatch.exe'
                                sleep 5
                        elif [ "$v" == WINNT ] ; then
                                if [ `cat $SCRIPTHOME/agentversion.txt` == 06.30.07.00 ] ; then
                                echo ""
                                echo "### Send files to the server 32 bit ###"
                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/kgs_winnt_tema_8.0.50.88.cab -d `cat $SCRIPTHOME/candlehome.txt`/Config/kgs_winnt_tema_8.0.50.88.cab -f

                                 tacmd putfile -m $zs -s /opt/patch/6.3.x-TIV-ITM-GSK-8.0.50.88-IJ04522/itmpatch.exe -d `cat $SCRIPTHOME/candlehome.txt`/config/itmpatch.exe -f

                                echo ""
                                echo "### Apply the interim fix on server @ gs @ ###"
                                echo " tacmd executecommand -m $zs -o -v -e -r -t 180 -c '`cat $SCRIPTHOME/candlehome.txt`\Config\itmpatch -h `cat $SCRIPTHOME/candlehome.txt` -i `cat \$SCRIPTHOME/candlehome.txt`\Config\kgs_winnt_tema_8.0.50.88.cab'" > $SCRIPTHOME/execommand.txt

                                $SCRIPTHOME/execommand.txt
                                sleep 5
                                echo ""
                                echo "### Remove files from the server ###"
                                 tacmd executecommand -m $zs -o -v -e -r -c 'del /f %CANDLE_HOME%\Config\kgs_winnt_tema_8.0.50.88.cab'
                                sleep 5
                                 tacmd executecommand -m $zs -o -v -e -r -c 'del /f %CANDLE_HOME%\Config\itmpatch.exe'
                                sleep 5
                                fi
                        fi
                done
        echo ""
        echo "### Check the GS version: @06.30.07.00 - IJ04522@ ###"
         tacmd executecommand -m $zs -o -v -e -r -c 'kincinfo -i -z'
        sleep 5
        fi
echo ""
echo "=============================================================="
echo "=============================END=============================="
echo "=============================================================="
echo ""
done
