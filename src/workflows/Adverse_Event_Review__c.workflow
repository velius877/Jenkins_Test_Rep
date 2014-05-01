<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_Case_Owner_when_Adverse_Event_Review_is_Complete</fullName>
        <description>Email to Case Owner when Adverse Event Review is Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>AR_Email_Templates/Notify_Case_Owner_when_Adverse_Event_Review_is_Complete</template>
    </alerts>
    <fieldUpdates>
        <fullName>Serious_AER</fullName>
        <field>Serious_Adverse_Event_Status__c</field>
        <literalValue>Yes</literalValue>
        <name>Serious AER</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>AER_Related_Case__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Notify Case Owner when Adverse Event Review is Complete</fullName>
        <actions>
            <name>Email_to_Case_Owner_when_Adverse_Event_Review_is_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Adverse_Event_Review__c.AER_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Serious AER</fullName>
        <actions>
            <name>Serious_AER</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Assessment_List__c, &quot;Serious&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
