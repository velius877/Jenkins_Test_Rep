<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Catalog_Unsubscribe_Timestamp</fullName>
        <field>Catalog_Unsubscribe_Date__c</field>
        <formula>TODAY()</formula>
        <name>Catalog Unsubscribe Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Catalog_Unsubscribe_Date</fullName>
        <field>Catalog_Unsubscribe_Date__c</field>
        <name>Clear Catalog Unsubscribe Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Catalog Unsubscribe Timestamp</fullName>
        <actions>
            <name>Catalog_Unsubscribe_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.No_Catalogs__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Creates a time stamp for when a customer asked to stop receiving catalogs</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>No Catalogs Uncheck</fullName>
        <actions>
            <name>Clear_Catalog_Unsubscribe_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.No_Catalogs__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Automatically clears the &quot;Catalog Unsubscribe Date&quot; field when &quot;No Catalogs?&quot; is unchecked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
