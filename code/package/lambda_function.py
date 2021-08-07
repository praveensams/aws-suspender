import json
import boto3
import os
import requests

regions=[ i for i in os.environ['regions'].replace('[','').replace(']','').split(',')]

def location(region):
    session = boto3.Session(aws_access_key_id=os.environ['aws_access'], aws_secret_access_key=os.environ['aws_secret'], region_name=region)
    ec2 = session.resource('ec2')
    return ec2


def lambda_handler(event, context):
    updates={}
    for loc in regions:
        print(loc)
        try:
            if os.environ['status'] == 'stop' and os.environ['SuspenderSchedule'] != 'always-on' and ( os.environ['SuspenderSchedule'] == 'business-hours' or os.environ['SuspenderSchedule'] == 'always-off' ):
                s=find_list(os.environ['SuspenderSchedule'],loc)
                s1=stop(s,loc)
                print(s,s1)
                send_message(s1,loc)
            elif os.environ['status'] == 'start' and os.environ['SuspenderSchedule'] == 'business-hours':
                s=find_list(os.environ['SuspenderSchedule'],loc)
                s1=start(s,loc)
                print("Sarting server")
                send_message(s1,loc)
        except Exception as e:
            print("Please check status and tags variable are set ==> {0}".format(e))
    return 

def find_list(tags,reg):
    ec2=location(reg)
    instance_list=[]
    for instance in ec2.instances.all():
        try:
            for i in instance.tags:
                if (i['Key'] == 'SuspenderSchedule' and (  i['Value'] == 'always-off' or  i['Value'] == tags ) and os.environ['status'] == 'stop'):
                    instance_list.append(instance.id)
                    print("hiii " + instance.id)
                elif i['Key'] == 'SuspenderSchedule' and  i['Value'] == tags and os.environ['status'] != 'stop':
                    instance_list.append(instance.id)
        except Exception as e:
            print(e)
    return(instance_list)

def stop(ins,reg):
    states=[]
    ec2=location(reg)
    instance_list=[]
    for i in ec2.instances.all():
        if i.id in ins:
            if i.state['Name'].lower() == "running":
                states.append(i.id)
    if len(states) > 0:
        ec2.instances.stop(InstanceIds=states)
        return states
    else:
        return


def start(ins,reg):
    states=[]
    ec2=location(reg)
    instance_list=[]
    for i in ec2.instances.all():
        if i.id in ins:
            if i.state['Name'].lower() != "running":
                states.append(i.id)
    if len(states) > 0:
        ec2.instances.start(InstanceIds=states)
        return states
    else:
        return


def send_message(msg,loc):
    WEBHOOK_URL = 'https://hooks.slack.com/services/Slackintegration'
    line="\n" + '-'*55 + "\n"
    try:
        if os.environ['status'] == 'stop':
            if len(msg) > 0:
                 msg=line + "    " + "* {0}    {1}*".format(os.environ["account_id"],loc) + "   " + line + "\n"  + " :desktop_computer: Following Ec2 instance going to stop in few mins :desktop_computer:  " + "\n" + line + "\n" + "\n".join(msg) + line
            else:
                msg=line + "* {0}  {1} *".format(os.environ["account_id"],loc) + line + ":desktop_computer: *No Ec2 instances are filtered on  given tags to Stopping* :desktop_computer:"  +  + line + "\n" + line 
        elif os.environ['status'] == 'start':
            if len(msg) > 0:
                msg=line + "    " + "* {0}    {1}*".format(os.environ["account_id"],loc) + "   " + line + "\n"  + " :desktop_computer: Following Ec2 instance going to start in few mins :desktop_computer:  " + "\n" + line + "\n" + "\n".join(msg) + line
            else:
                msg=line + "* {0}  {1} *".format(os.environ["account_id"],loc) + line + ":desktop_computer: * No Ec2 instances are filtered on  given tags to starting* :desktop_computer:"  +  line
    except Exception as e:
        msg=line + "* {0}  {1} *".format(os.environ["account_id"],loc) + line + ":desktop_computer: * No Ec2 instances are filtered on  given tags to {0}* :desktop_computer:".format(os.environ['status'])  +  line
    #msg="* Running Suspendar Scripts *" + "\n" + msg
    message = {
	        "blocks": [
	    	    {
    			"type": "section",
    			"text": {
    				"type": "mrkdwn",
    				"text": msg
			        }
	        	}
        	    ]
            }
    print(message)
    response = requests.post(WEBHOOK_URL, data=json.dumps(message),headers={'Content-Type': 'application/json'})
