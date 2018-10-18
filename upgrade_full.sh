#!/bin/ksh



SCRIPTHOME=/home/huh90029/upgrade


for i in `cat $SCRIPTHOME/servername.txt`
do
echo $i
tacmd listsystems -t ux | grep -i $i | awk '{print$1}' > $SCRIPTHOME/osagent.txt
tacmd listsystems -t lz | grep -i $i | awk '{print$1}' >> $SCRIPTHOME/osagent.txt
tacmd listsystems -t nt | grep -i $i | awk '{print$1}' >> $SCRIPTHOME/osagent.txt
tacmd listsystems | grep -i $i | awk '{print$2}' | grep -i ux > $SCRIPTHOME/ostype.txt
tacmd listsystems | grep -i $i | awk '{print$2}' | grep -i lz >> $SCRIPTHOME/ostype.txt
tacmd listsystems | grep -i $i | awk '{print$2}' | grep -i nt >> $SCRIPTHOME/ostype.txt


OSAGENT=`cat $SCRIPTHOME/osagent.txt`
OSTYPE=`cat $SCRIPTHOME/ostype.txt`
FREESPACE=`tacmd executecommand -m $OSAGENT -o -v -e -r -c 'df -m \$CANDLEHOME' | awk '{print\$3}' | grep [0-9]`
ONLINE=`tacmd listsystems -t $OSTYPE | grep -i $i | awk '{print\$4}'`


        if [ "$ONLINE" = "Y" ] ; then
                if [ "$OSTYPE" == UX ] && [ "$FREESPACE" -gt 900 ] ; then
                echo "----- UPDATING THE -- $i -- OSAGENT -----"
                        for j in `tacmd updateagent -f -t ux -n $OSAGENT | grep KUICUA027I | awk '{print $14}'| awk -F ',' '{print $1}'`
                        do
                        echo ""
                        echo "-- Checking the $j distribution on $i ---- "
                        echo ""

                        SUCCESS=SUCCESS
                        FAILED=FAILED
                        RETRYING=RETRYABLE
                        INPROGRESS=INPROGRESS
                        STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`

                                while [ "$STATUS" != "$SUCCESS" ]
                                do
                                sleep 10
                                STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`
                                        if [ "$STATUS" = "$FAILED" ] ; then
                                                echo `date +%H:%M` " -- The $j distribution status on $i is FAILED"
                                                tacmd getdeploystatus -g $j | grep Error
                                                break
                                        elif [ "$STATUS" = "$RETRYING" ] ; then
                                                RETRIES=`tacmd getdeploystatus -g $j | grep -i Retries`
                                                echo `date +%H:%M` "  -- The distribution status on $i is RETRYING - Number of $RETRIES"
                                                sleep 180
                                        elif [ "$STATUS" = "$SUCCESS" ] ; then
                                                echo `date +%H:%M` "  -- The distribution status on $i is SUCCESSFUL"
                                                echo""
                                                echo "--- Checking Upgraded Agent -----------------------------------------------------"
                                                echo ""
                                                echo " -- Agent status ----"
                                                tacmd listsystems | grep -i $i
                                                echo ""
                                                sleep 5
                                                echo "---------------------------------------------------------------------------------"
                                        elif [ "$STATUS" = "$INPROGRESS" ] ; then
                                                echo `date +%H:%M` "  -- The distribution status on $i is INPROGRESS"
                                                sleep 180
                                        else
                                        echo "---- The distribution was cleared !!! -----"
                                        break
                                        fi
                                done
                        echo ""
                        echo "################################################################################"
                        done

                        tacmd listsystems | grep -i $i | awk '{print$2}' | grep -i 07 > $SCRIPTHOME/bcagent.txt
                        OSTYPEBC=`cat $SCRIPTHOME/bcagent.txt`
                        ONLINEBC=`tacmd listsystems -t $OSTYPEBC | grep -i $i | awk '{print\$4}'` 
                        if [ "$OSTYPEBC" == 07 ] && [ "$ONLINEBC" == "Y" ] ; then
                                echo "----- UPDATING THE -- $i -- BCAGENT -----"
                                for j in `tacmd updateagent -f -t 07 -n $OSAGENT | grep KUICUA027I | awk '{print $14}'| awk -F ',' '{print $1}'`
                                do
                                echo ""
                                echo "-- Checking the $j distribution on $i ---- "
                                echo ""

                                SUCCESS=SUCCESS
                                FAILED=FAILED
                                RETRYING=RETRYABLE
                                INPROGRESS=INPROGRESS
                                STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`

                                        while [ "$STATUS" != "$SUCCESS" ]
                                        do
                                        sleep 10
                                        STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`
                                                if [ "$STATUS" = "$FAILED" ] ; then
                                                        echo `date +%H:%M` " -- The $j distribution status on $i is FAILED"
                                                        tacmd getdeploystatus -g $j | grep Error
                                                        break
                                                elif [ "$STATUS" = "$RETRYING" ] ; then
                                                        RETRIES=`tacmd getdeploystatus -g $j | grep -i Retries`
                                                        echo `date +%H:%M` "  -- The distribution status on $i is RETRYING - Number of $RETRIES"
                                                        sleep 180
                                                elif [ "$STATUS" = "$SUCCESS" ] ; then
                                                        echo `date +%H:%M` "  -- The distribution status on $i is SUCCESSFUL"
                                                        echo ""
                                                        echo "--- Checking Upgraded Agent -----------------------------------------------------"
                                                        echo ""
                                                        echo " -- Agent status ----"
                                                        tacmd listsystems | grep -i $i
                                                        echo ""
                                                        sleep 5
                                                        echo "---------------------------------------------------------------------------------"
                                                elif [ "$STATUS" = "$INPROGRESS" ] ; then
                                                        echo `date +%H:%M` "  -- The distribution status on $i is INPROGRESS"
                                                        sleep 180
                                                else
                                                echo "---- The distribution was cleared !!! -----"
                                                break
                                                fi
                                        done
                                echo ""
                                echo "###########################################################"      
                                done
                        else
                                echo "BC Agent is offline or didn't find any on the server please check below"
                                tacmd listsystems | grep -i $i
                        fi
 
        elif [ "$OSTYPE" == LZ ] && [ "$FREESPACE" -gt 900 ] ; then
                echo "----- UPDATING THE -- $i -- OSAGENT -----"
                        for j in `tacmd updateagent -f -t lz -n $OSAGENT | grep KUICUA027I | awk '{print $14}'| awk -F ',' '{print $1}'`
                        do
                        echo ""
                        echo "-- Checking the $j distribution on $i ---- "
                        echo ""

                        SUCCESS=SUCCESS
                        FAILED=FAILED
                        RETRYING=RETRYABLE
                        INPROGRESS=INPROGRESS
                        STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`

                                while [ "$STATUS" != "$SUCCESS" ]
                                do
                                sleep 10
                                STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`
                                        if [ "$STATUS" = "$FAILED" ] ; then
                                                echo `date +%H:%M` " -- The $j distribution status on $i is FAILED"
                                                tacmd getdeploystatus -g $j | grep Error
                                                break
                                        elif [ "$STATUS" = "$RETRYING" ] ; then
                                                RETRIES=`tacmd getdeploystatus -g $j | grep -i Retries`
                                                echo `date +%H:%M` "  -- The distribution status on $i is RETRYING - Number of $RETRIES"
                                                sleep 180
                                        elif [ "$STATUS" = "$SUCCESS" ] ; then
                                                echo `date +%H:%M` "  -- The distribution status on $i is SUCCESSFUL"
                                                echo""
                                                echo "--- Checking Upgraded Agent -----------------------------------------------------"
                                                echo ""
                                                echo " -- Agent status ----"
                                                tacmd listsystems | grep -i $i
                                                echo ""
                                                sleep 5
                                                echo "---------------------------------------------------------------------------------"
                                        elif [ "$STATUS" = "$INPROGRESS" ] ; then
                                                echo `date +%H:%M` "  -- The distribution status on $i is INPROGRESS"
                                                sleep 180
                                        else
                                        echo "---- The distribution was cleared !!! -----"
                                        break
                                        fi
                                done

                        echo ""
                        echo "################################################################################"
                        done


                        tacmd listsystems | grep -i $i | awk '{print$2}' | grep -i 08 > $SCRIPTHOME/bcagent.txt
                        OSTYPEBC=`cat $SCRIPTHOME/bcagent.txt`
                        ONLINEBC=`tacmd listsystems -t $OSTYPEBC | grep -i $i | awk '{print\$4}'` 
                        if [ "$OSTYPEBC" == 08 ] && [ "$ONLINEBC" == "Y" ] ; then
                                echo "----- UPDATING THE -- $i -- BCAGENT -----"
                                for j in `tacmd updateagent -f -t 08 -n $OSAGENT | grep KUICUA027I | awk '{print $14}'| awk -F ',' '{print $1}'`
                                do
                                echo ""
                                echo "-- Checking the $j distribution on $i ---- "
                                echo ""

                                SUCCESS=SUCCESS
                                FAILED=FAILED
                                RETRYING=RETRYABLE
                                INPROGRESS=INPROGRESS
                                STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`

                                        while [ "$STATUS" != "$SUCCESS" ]
                                        do
                                        sleep 10
                                        STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`
                                                if [ "$STATUS" = "$FAILED" ] ; then
                                                        echo `date +%H:%M` " -- The $j distribution status on $i is FAILED"
                                                        tacmd getdeploystatus -g $j | grep Error
                                                        break
                                                elif [ "$STATUS" = "$RETRYING" ] ; then
                                                        RETRIES=`tacmd getdeploystatus -g $j | grep -i Retries`
                                                        echo `date +%H:%M` "  -- The distribution status on $i is RETRYING - Number of $RETRIES"
                                                        sleep 180
                                                elif [ "$STATUS" = "$SUCCESS" ] ; then
                                                        echo `date +%H:%M` "  -- The distribution status on $i is SUCCESSFUL"
                                                        echo ""
                                                        echo "--- Checking Upgraded Agent -----------------------------------------------------"
                                                        echo ""
                                                        echo " -- Agent status ----"
                                                        tacmd listsystems | grep -i $i
                                                        echo ""
                                                        sleep 5
                                                        echo "---------------------------------------------------------------------------------"
                                                elif [ "$STATUS" = "$INPROGRESS" ] ; then
                                                        echo `date +%H:%M` "  -- The distribution status on $i is INPROGRESS"
                                                        sleep 180
                                                else
                                                echo "---- The distribution was cleared !!! -----"
                                                break
                                                fi
                                        done
                                echo ""
                                echo "###########################################################"      
                                done
                        else
                                echo "BC Agent is offline or didn't find any on the server please check below"
                                tacmd listsystems | grep -i $i
                        fi
 
 elif [ "$OSTYPE" == NT ] ; then
                        echo "----- UPDATING THE -- $i -- OSAGENT -----"
                        for j in `tacmd updateagent -f -t nt -n $OSAGENT | grep KUICUA027I | awk '{print $14}'| awk -F ',' '{print $1}'`
                        do
                        echo ""
                        echo "-- Checking the $j distribution on $i ---- "
                        echo ""

                        SUCCESS=SUCCESS
                        FAILED=FAILED
                        RETRYING=RETRYABLE
                        INPROGRESS=INPROGRESS
                        STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`

                                while [ "$STATUS" != "$SUCCESS" ]
                                do
                                sleep 10
                                STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`
                                        if [ "$STATUS" = "$FAILED" ] ; then
                                                echo `date +%H:%M` " -- The $j distribution status on $i is FAILED"
                                                tacmd getdeploystatus -g $j | grep Error
                                                break
                                        elif [ "$STATUS" = "$RETRYING" ] ; then
                                                RETRIES=`tacmd getdeploystatus -g $j | grep -i Retries`
                                                echo `date +%H:%M` "  -- The distribution status on $i is RETRYING - Number of $RETRIES" >> $SCRIPTHOME/Retriesnumber.txt
                                                sleep 180
                                                        RETRIESNUMBER=`cat $SCRIPTHOME/Retriesnumber.txt | wc -l`
                                                        if [ "$RETRIESNUMBER" -gt 10 ] ; then
                                                        > $SCRIPTHOME/Retriesnumber.txt
                                                        tacmd cleardeploystatus -g $j
                                                        break
                                                        fi
                                        elif [ "$STATUS" = "$SUCCESS" ] ; then
                                                echo `date +%H:%M` "  -- The distribution status on $i is SUCCESSFUL"
                                                echo ""
                                                echo "--- Checking Upgraded Agent -----------------------------------------------------"
                                                echo ""
                                                echo " -- Agent status ----"
                                                tacmd listsystems | grep -i $i
                                                echo ""
                                                sleep 5
                                                echo "---------------------------------------------------------------------------------"
                                        elif [ "$STATUS" = "$INPROGRESS" ] ; then
                                                echo `date +%H:%M` "  -- The distribution status on $i is INPROGRESS"
                                                sleep 180
                                        else
                                        echo "---- The distribution was cleared !!! -----"
                                        break
                                        fi
                                done

                        echo ""
                        echo "################################################################################"
                        done


                        tacmd listsystems | grep -i $i | awk '{print$2}' | grep -i 06 > $SCRIPTHOME/bcagent.txt
                        OSTYPEBC=`cat $SCRIPTHOME/bcagent.txt`
                        ONLINEBC=`tacmd listsystems -t $OSTYPEBC | grep -i $i | awk '{print\$4}'` 
                        if [ "$OSTYPEBC" == 06 ] && [ "$ONLINEBC" == "Y" ] ; then
                                echo "----- UPDATING THE -- $i -- BCAGENT -----"
                                for j in `tacmd updateagent -f -t 06 -n $OSAGENT | grep KUICUA027I | awk '{print $14}'| awk -F ',' '{print $1}'`
                                do
                                echo ""
                                echo "-- Checking the $j distribution on $i ---- "
                                echo ""

                                SUCCESS=SUCCESS
                                FAILED=FAILED
                                RETRYING=RETRYABLE
                                INPROGRESS=INPROGRESS
                                STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`

                                        while [ "$STATUS" != "$SUCCESS" ]
                                        do
                                        sleep 10
                                        STATUS=`tacmd getdeploystatus -g $j | grep -i status | grep -i -v error | awk '{print $3}'`
                                                if [ "$STATUS" = "$FAILED" ] ; then
                                                        echo `date +%H:%M` " -- The $j distribution status on $i is FAILED"
                                                        tacmd getdeploystatus -g $j | grep Error
                                                        break
                                                elif [ "$STATUS" = "$RETRYING" ] ; then
                                                        RETRIES=`tacmd getdeploystatus -g $j | grep -i Retries`
                                                        echo `date +%H:%M` "  -- The distribution status on $i is RETRYING - Number of $RETRIES"
                                                        sleep 180
                                                elif [ "$STATUS" = "$SUCCESS" ] ; then
                                                        echo `date +%H:%M` "  -- The distribution status on $i is SUCCESSFUL"
                                                        echo ""
                                                        echo "--- Checking Upgraded Agent -----------------------------------------------------"
                                                        echo ""
                                                        echo " -- Agent status ----"
                                                        tacmd listsystems | grep -i $i
                                                        echo ""
                                                        sleep 5
                                                        echo "---------------------------------------------------------------------------------"
                                                elif [ "$STATUS" = "$INPROGRESS" ] ; then
                                                        echo `date +%H:%M` "  -- The distribution status on $i is INPROGRESS"
                                                        sleep 180
                                                else
                                                echo "---- The distribution was cleared !!! -----"
                                                break
                                                fi
                                        done
                                echo ""
                                echo "###########################################################"      
                                done
                        else
                                echo "BC Agent is offline or didn't find any on the server please check below"
                                tacmd listsystems | grep -i $i
                        fi

                else
                        echo "Not enough space on the server"
                        echo "Freespace: $FREESPACE MB"
                fi
        else
        echo "OS Agent is offline"
        fi
done
