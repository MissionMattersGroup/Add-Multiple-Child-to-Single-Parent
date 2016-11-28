public with sharing class Addmultiplechildrecordscontroller {

        public List<SObject> SObjectList {get; set; }
        public List<String> SObjectChildfieldList {get; set; }
        public List<SObject> SObjectExistingChildList {get; set; }
        public List<SObject> SObjectInsertedChildList {get; set; }
        public List<Schema.FieldSetMember> listparentFieldSetMember {get; set; }
        public List<Schema.FieldSetMember> listChildFieldSetMember {get; set; }
        public List<ChildSObjectWrapper> createNewSObjectList {get; set; }
        public String strChildRecId { get; set { strChildRecId = value; } }
        public String strAddNoRecords {get; set; }
        public String strHeaderRowValue {get; set; }
        public String render {get; set; }
        public Blob csvFileBody {get; set; }
        public String csvAsString {get; set; }
        public String[] csvFileLines {get; set; }
        public String[] strHeaderRow {get; set; }
        public Boolean isVisible {get; set; }
        public Boolean isPageVisible {get; set; }
        public Boolean isSaveMessage {get; set; }
        public Boolean isDeleterMessage {get; set; }
        public Boolean isFileVisible {get; set; }
        public Boolean isFileUploaded {get; set; }
        public Boolean renderRelatedAPIField {get; set;}
        public List<ChildSObjectEditWrapper> lstChildWrp {get; set; }
        public Map<Integer, ChildSObjectEditWrapper> lstChildWrpMap {get; set; }
        public Settings__c objSetting {get; set; }
        public static Settings__c objSettingForDelete;
        public Map<String, String> paramMap;
        public String objChildConId {get; set; }
        public List<SObject> SObjectChildList;
        public List<String> SObjectfieldList;
        public String strParentId;
        public String strFieldsetObjectAssociationId;
        public String strReturnURL;
        public String strSObjectId;
        public Set<Id> setInsertedchildId;
        public Integer rowNumber;
        public Integer rowIndex {get; set; }
        public Integer assignedRowNumber {get; set; }
        private SObject objChildSObject;
        private SObject objChildSObjectTemp;
        public List<ChildSObjectEditWrapper> childDataList {get; set; }
        public Map<String, String> mapChildFieldApi_HelpText{get;set;}
        public Map<String, String> mapParentFieldApi_HelpText{get;set;}

        public Addmultiplechildrecordscontroller () {
            paramMap = Apexpages.currentPage().getParameters();
            childDataList = new List<ChildSObjectEditWrapper>();
            mapChildFieldApi_HelpText = new Map<String, String>();
            mapParentFieldApi_HelpText = new Map<String, String>();
            init();
        }

        public void init() {
            isPageVisible = true;
            isFileVisible = true;
            if(String.isBlank(ApexPages.currentPage().getParameters().get('po'))||
               String.isBlank(ApexPages.currentPage().getParameters().get('pretURL')) ||
               String.isBlank(ApexPages.currentPage().getParameters().get('pid'))) {
                    isPageVisible = false;
                    showError('Inappropriate input prameters provided. Please provide valid input parameters to continue viewing this page.');
            } else {
                strFieldsetObjectAssociationId = ApexPages.currentPage().getParameters().get('po');
                strReturnURL = ApexPages.currentPage().getParameters().get('pretURL');
                strSObjectId = ApexPages.currentPage().getParameters().get('pid');
                isVisible = false;
                isSaveMessage = false;
                isDeleterMessage = false;
                isFileUploaded = false;
                renderRelatedAPIField = true;
                rowNumber = 0;
                strAddNoRecords = '';
                objSetting = new Settings__c();
                createNewSObjectList = new List<ChildSObjectWrapper>();
                SObjectList = new List<SObject>();
                SObjectfieldList = new List<String>();
                SObjectChildfieldList = new List<String>();
                SObjectExistingChildList = new List<SObject>();
                SObjectInsertedChildList = new List<SObject>();
                listparentFieldSetMember= new  List<Schema.FieldSetMember>();
                lstChildWrp = new List<ChildSObjectEditWrapper> ();
                SObjectList = new List<SObject>();
                SObjectChildList = new List<SObject>();
                listChildFieldSetMember = new List<Schema.FieldSetMember>();
                retrieveFieldSetObjectRec();
                retrieveParentObjectRecord();
                retrieveChildFieldset(NULL);
                if(Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c ) !=null) {
                    objChildSObject = Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c ).getDescribe().SObjectType.newSObject(null,false);
                    for (Schema.FieldSetMember fsm : listChildFieldSetMember) {
                        if (fsm.getFieldPath().equalsIgnoreCase(objSetting.Related_Field_API_Name__c)) {
                            renderRelatedAPIField = false;
                        }
                    }
                }
                createNewChildRecord();
                childDataList = getChildData ();
            }
        }

        public void showError(String pErrorMessage) {
            isVisible = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, pErrorMessage);
            ApexPages.addMessage(myMsg);
        }

        public static String generateQueryString(String pObjectName, String pFieldValue, String pWhereClauseField, String pQuerySearchId){
            return 'SELECT ' + pFieldValue + ' FROM ' + pObjectName + ' WHERE ' + pWhereClauseField + ' = \'' + pQuerySearchId + '\'';
        }

        public void retrieveParentObjectRecord() {
            listparentFieldSetMember= new List<Schema.FieldSetMember>();
            String strFieldValue = '';
            String strQuery = '';
            Schema.FieldSet fieldSetObj = retrieveFieldSetObj(objSetting.Parent_SObject_Name__c, objSetting.Parent_Fieldset_Name__c);
            if(fieldSetObj != null && fieldSetObj.getFields() != null && !fieldSetObj.getFields().IsEmpty()) {
                listparentFieldSetMember = fieldSetObj.getFields();
                for(Schema.FieldSetMember objFields : fieldSetObj.getFields()) {
                    strFieldValue = String.isBlank(strFieldValue) ? objFields.getFieldPath() : strFieldValue + ' , ' + objFields.getFieldPath();
                    SObjectfieldList.add(objFields.getFieldPath());
                }
                if(!SObjectfieldList.isEmpty()) mapParentFieldApi_HelpText = createChildMapFieldwithHelpText(objSetting.Parent_SObject_Name__c, SObjectfieldList);
                strQuery = generateQueryString(objSetting.Parent_SObject_Name__c, strFieldValue.removeEnd(','), ' id ', strSObjectId);
                try {
                    SObjectList = Database.query(strQuery);
                } catch(Exception ex) {
                    showError(ex.getMessage());
                }
            }
        }

        public Map<String, String> createChildMapFieldwithHelpText(String strObjectName,List<String> lstSObjectfieldApi) {
            Schema.DescribeSObjectResult obj = Schema.getGlobalDescribe().get(strObjectName).getDescribe();
            Map<String, String> mapFieldApi_HelpText = new Map<String, String>();
            for(String strFieldApi : lstSObjectfieldApi) {
                Schema.DescribeFieldResult fieldResult = obj.Fields.getMap().get(strFieldApi).getDescribe();
                if(fieldResult.getInlinehelpText() != null) {
                    mapFieldApi_HelpText.put(strFieldApi,fieldResult.getInlinehelpText());
                } else {
                    mapFieldApi_HelpText.put(strFieldApi,'');
                }
            }
            return mapFieldApi_HelpText;
        }

        public void createNewChildRecord() {
            isFileVisible = false;
            strAddNoRecords = String.isEmpty(Apexpages.currentpage().getparameters().get('pAddrowNumber')) ? '1' : Apexpages.currentpage().getparameters().get('pAddrowNumber');
            if(objSetting.Child_SObject_Name__c != null && objSetting.Child_SObject_Name__c != '') {
                SObjectType soType = Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c);
                if(soType != null ) {
                    Map<String,Schema.SObjectField> mfields = soType.getDescribe().fields.getMap();
                    if(mfields.containsKey(objSetting.Related_Field_API_Name__c)) {
                        for(Integer i=0; i<Integer.valueOf(strAddNoRecords); i++) {
                            objChildSObjectTemp = Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c).getDescribe().SObjectType.newSObject(null,false);
                            for(Integer j=0; j<listChildFieldSetMember.size(); j++) {
                                Schema.DisplayType fieldType = listChildFieldSetMember[j].getType();
                                if(paramMap.containsKey(listChildFieldSetMember[j].FieldPath)) {
                                    if(fieldType == Schema.Displaytype.Date) {
                                        objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, Date.parse(paramMap.get(listChildFieldSetMember[j].FieldPath)));
                                    } else if (fieldType == Schema.Displaytype.Datetime) {
                                        objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, Datetime.parse(paramMap.get(listChildFieldSetMember[j].FieldPath)));
                                    } else if (fieldType == Schema.Displaytype.Integer) {
                                        objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, Integer.valueOf(paramMap.get(listChildFieldSetMember[j].FieldPath)));
                                    } else if (fieldType == Schema.Displaytype.Currency) {
                                        objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, Decimal.valueOf(paramMap.get(listChildFieldSetMember[j].FieldPath)));
                                    } else if (fieldType == Schema.Displaytype.Double) {
                                        objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, Double.valueOf(paramMap.get(listChildFieldSetMember[j].FieldPath)));
                                    } else {
                                        objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, paramMap.get(listChildFieldSetMember[j].FieldPath));
                                    }
                                } else {
                                    objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath, objChildSObject.get(listChildFieldSetMember[j].FieldPath));
                                }
                            }
                            objChildSObjectTemp.put(objSetting.Related_Field_API_Name__c, strSObjectId);
                            createNewSObjectList.add(new ChildSObjectWrapper(++rowNumber,objChildSObjectTemp));
                        }
                    } else {
                        isPageVisible = false;
                        showError('Inappropriate Settings values encountered. Please navigate to the Settings tab and verify the configured record values or contact your Salesforce administrator.');
                    }
                }
            }
            isFileVisible = true;
        }

<<<<<<< HEAD
                SObjectType sobjectType = Schema.getGlobalDescribe().get(objSetting.Child_Sobject_Name__c);
                if(sobjectType != null ) {

                    Map<String,Schema.SObjectField> mfields = sobjectType.getDescribe().fields.getMap();
                    if(mfields.containsKey(objSetting.Related_Field_API_Name__c)) {
                        if(assignedRowNumber != null){
                        
                            objChildSobjectTemp = Schema.getGlobalDescribe().get(objSetting.Child_Sobject_Name__c ).getDescribe().sobjectType.newSObject(null,false);
                            for(integer j=0; j<listChildFieldSetMember.size(); j++) {
                                Schema.DisplayType fieldType = listChildFieldSetMember[j].getType();
                                objChildSobjectTemp.put(listChildFieldSetMember[j].FieldPath,createNewSobjectList[assignedRowNumber-1].objCreateSobject.get(listChildFieldSetMember[j].FieldPath));
                                
                            }
                            objChildSobjectTemp.put(objSetting.Related_Field_API_Name__c, strSobjectId);
                            createNewSobjectList.add(new childSobjectWrapper(++rowNumber, objChildSobjectTemp));
                            
=======
        public PageReference addCloneChildRecord() {
            if(objSetting.Child_SObject_Name__c != null && objSetting.Child_SObject_Name__c != '') {
                SObjectType SObjectType = Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c);
                if(SObjectType != null ) {
                    Map<String,Schema.SObjectField> mfields = SObjectType.getDescribe().fields.getMap();
                    if(mfields.containsKey(objSetting.Related_Field_API_Name__c) & assignedRowNumber != null) {
                        objChildSObjectTemp = Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c ).getDescribe().SObjectType.newSObject(null,false);
                        for(Integer j=0; j<listChildFieldSetMember.size(); j++) {
                            Schema.DisplayType fieldType = listChildFieldSetMember[j].getType();
                            objChildSObjectTemp.put(listChildFieldSetMember[j].FieldPath,createNewSObjectList[assignedRowNumber-1].objCreateSObject.get(listChildFieldSetMember[j].FieldPath));
>>>>>>> refs/remotes/origin/master
                        }
                        createNewSObjectList.add(new ChildSObjectWrapper(++rowNumber, objChildSObjectTemp));
                    }
                }
            }
            return null;
        }

        public void retrieveFieldSetObjectRec() {
            List<Settings__c> settingsList = [SELECT Id, Parent_Fieldset_Name__c, Parent_SObject_Name__c, Parent_Section_Title__c, Child_Fieldset_Name__c, Child_SObject_Name__c, Related_Field_API_Name__c, Child_Section_Title__c, Existing_Child_Records_Title__c, Child_Display_Name__c, Provide_CSV_Upload__c FROM Settings__c WHERE Id = :strFieldsetObjectAssociationId];
            objSetting = new Settings__c();
            objSettingForDelete = new Settings__c();
            if(settingsList<> null && !settingsList.isEmpty()) {
                objSetting = settingsList.get(0);
                objSettingForDelete = settingsList.get(0);
            }
        }

        public void retrieveChildFieldset(set<Id> setChildIds) {
            String strFieldValue = '';
            String strQuery = '';
            isSaveMessage = false;
            isDeleterMessage = false;
            SObjectExistingChildList = new List<SObject>();
            SObjectInsertedChildList = new List<SObject>();
            SObjectChildfieldList = new List<String>();
            listChildFieldSetMember = new List<Schema.FieldSetMember>();
            Schema.FieldSet fieldSetObj = retrieveFieldSetObj(objSetting.Child_SObject_Name__c,objSetting.Child_Fieldset_Name__c);
            try {
                if(fieldSetObj != null && fieldSetObj.getFields() != null && !fieldSetObj.getFields().IsEmpty()) {
                    listChildFieldSetMember = fieldSetObj.getFields();
                    for(Schema.FieldSetMember objFields : fieldSetObj.getFields()) {
                        strFieldValue = String.isBlank(strFieldValue) ? objFields.getFieldPath() : strFieldValue + ', ' + objFields.getFieldPath();
                        SObjectChildfieldList.add(objFields.getFieldPath());
                    }
                    if(!SObjectChildfieldList.isEmpty()) mapChildFieldApi_HelpText = createChildMapFieldwithHelpText(objSetting.Child_SObject_Name__c, SObjectChildfieldList);
                    strQuery = generateQueryString(objSetting.Child_SObject_Name__c, strFieldValue.removeEnd(','), objSetting.Related_Field_API_Name__c, strSObjectId);
                    if(setChildIds != NULL && setChildIds.size() > 0) {
                        strQuery += ' AND Id IN :setChildIds';
                        SObjectInsertedChildList = Database.query(strQuery);
                    } else {
                        fillWrapperList(strQuery);
                    }
                }
            } catch(System.QueryException queryException) {
                showError(queryException.getMessage());
            }
        }

        public void fillWrapperList(String queryStr) {
            lstChildWrpMap = new Map<Integer, ChildSObjectEditWrapper> ();
            Integer i = 0;
            for (SObject obj : Database.query(queryStr)) {
                ChildSObjectEditWrapper childWrp = new ChildSObjectEditWrapper ();
                childWrp.editRecord = false;
                childWrp.objChildSObject = obj;
                childWrp.rowIndexNo = i;
                lstChildWrpMap.put (i, childWrp);
                lstChildWrp.add (childWrp);
                i++;
            }
        }

        public List<ChildSObjectEditWrapper> getChildData () {
            if (lstChildWrpMap == null) { return null; }
            return lstChildWrpMap.values();
        }

        public void editChildFieldset() {
            if(rowIndex != null && lstChildWrpMap.containsKey(rowIndex) && !lstChildWrpMap.get(rowIndex).editRecord) lstChildWrpMap.get(rowIndex).editRecord = true;
            getChildData();
            isSaveMessage = false;
            isDeleterMessage = false;
        }

        public void saveChildFieldset() {
            if (rowIndex != null && lstChildWrpMap.containsKey(rowIndex))  {
                lstChildWrpMap.get(rowIndex).editRecord = false;
                update lstChildWrpMap.get(rowIndex).objChildSObject;
            }
        }

        public void cancelChildContact(Integer rowIndex) {
            if(rowIndex != null && rowIndex >= 0){
                String strFieldValue = '';
                String strQuery = '';
                SObjectChildfieldList = new List<String>();
                listChildFieldSetMember = new List<Schema.FieldSetMember>();
                Schema.FieldSet fieldSetObj = retrieveFieldSetObj(objSetting.Child_SObject_Name__c,objSetting.Child_Fieldset_Name__c);
                try {
                    if(fieldSetObj != null && fieldSetObj.getFields() != null && !fieldSetObj.getFields().IsEmpty()) {
                        listChildFieldSetMember = fieldSetObj.getFields();
                        for(Schema.FieldSetMember objFields : fieldSetObj.getFields()) {
                            strFieldValue = String.isBlank(strFieldValue) ? objFields.getFieldPath() : strFieldValue + ', ' + objFields.getFieldPath();
                            SObjectChildfieldList.add(objFields.getFieldPath());
                        }
                        strQuery = generateQueryString(objSetting.Child_SObject_Name__c, strFieldValue.removeEnd(','), objSetting.Related_Field_API_Name__c, strSObjectId) + ' AND ID =\''+ childDataList[rowIndex].objChildSObject.Id + '\'';
                        SObject cancelObj = Database.Query(strQuery);
                        childDataList[rowIndex].editRecord = false;
                        childDataList[rowIndex].objChildSObject = cancelObj;
                    }
                } catch(System.QueryException queryException) {
                    showError(queryException.getMessage());
                }
            }
        }
        public void cancelChildFieldset() {
            if (rowIndex != null && lstChildWrpMap.containsKey(rowIndex))  {
                lstChildWrpMap.get(rowIndex).editRecord = false;
                cancelChildContact(rowIndex);
            }
        }

        public Schema.FieldSet retrieveFieldSetObj(String pstrObjectName, String pstrFieldSetName){
            if(!Schema.getGlobalDescribe().containsKey(pstrObjectName)) {
                isPageVisible = false;
                showError('Inappropriate Settings values encountered. Please navigate to the Settings tab and verify the configured record values or contact your Salesforce administrator.');
                return null;
            }
            Schema.DescribeSObjectResult SObjectDescribeResult = Schema.getGlobalDescribe().get(pstrObjectName).getDescribe();
            if(!SObjectDescribeResult.FieldSets.getMap().containsKey(pstrFieldSetName)) {
                isPageVisible = false;
                showError('Inappropriate Settings values encountered. Please navigate to the Settings tab and verify the configured record values or contact your Salesforce administrator.');
                return null;
            }
            return SObjectDescribeResult.FieldSets.getMap().get(pstrFieldSetName);
        }

        public PageReference saveChildObject() {
            isSaveMessage = true;
            PageReference objPageReference;
            setInsertedchildId = new Set<Id>();
            List<SObject> SObjectToInsert = new List<SObject>();
            if(createNewSObjectList != null && !createNewSObjectList.IsEmpty()) {
                for(ChildSObjectWrapper objcreateNewSObject : createNewSObjectList) {
                    SObjectToInsert.add(objcreateNewSObject.objCreateSObject);
                }
            }
            if(SObjectToInsert == null || SObjectToInsert.isEmpty()) {
                showError('There are no records to save. Please add the records before saving the records.');
                return null;
            }
            try {
                Database.Saveresult[] saveResult = Database.insert(SObjectToInsert);
                Database.SaveResult sr = saveResult[0];
                if(sr.isSuccess()) {
                    for(SObject sObj : SObjectToInsert) {
                        setInsertedchildId.add(String.valueOf(sObj.get('Id')));
                    }
                    objPageReference = new PageReference('/' + strSObjectId);
                    objPageReference.setRedirect(true);
                }
                else {
                    Database.Error[] errors = sr.getErrors();
                    for (Database.Error err : errors) {
                        showError(err.getMessage());
                    }
                }
            }
            catch(DMLException ex){
                    ShowError(ex.getMessage());
            }
            return objPageReference;
        }

        public PageReference showInsertedChildRecords() {
            quickSaveRecords();
            retrieveChildFieldset(setInsertedchildId);
            return null;
        }

        public void quickSaveRecords() {
            SObjectExistingChildList = new List<SObject>();
            SObjectInsertedChildList = new List<SObject>();
            SObjectChildfieldList = new List<String>();
            saveChildObject();
            rowNumber = 0;
            isVisible = false;
            isDeleterMessage = false;
        }

        public PageReference quickSaveChildRecords() {
            quickSaveRecords();
            retrieveChildFieldset(null);
            childDataList = getChildData();
            isSaveMessage = true;
			return null;
        }

        @RemoteAction
        public static String deleteChildRecord(String pStrDelObjId,String pStrchildObjName){
            String strQuery = generateQueryString(pStrchildObjName, 'Id', 'Id', pStrDelObjId);
            List<SObject> ListDeletingRec = Database.query(strQuery);
            if(ListDeletingRec != null && !ListDeletingRec.isEmpty()) {
                try {
                    delete ListDeletingRec;
                    return 'true';
                } catch(System.DmlException dmlException){
                    return dmlException.getMessage();
                }
            }
            return 'true';
        }

        public Pagereference removeItem() {
            Map<Integer,Integer> mapRemoveRecord = new Map<Integer,Integer>();
            if (this.createNewSObjectList == null || this.createNewSObjectList.isEmpty()) return null;
            Integer cnt = 0;
            for(ChildSObjectWrapper objCreatenewObject : createNewSObjectList) {
                mapRemoveRecord.put(objCreatenewObject.iRecNo, cnt);
                cnt++;
            }
            createNewSObjectList.remove( mapRemoveRecord.get(Integer.valueOf(apexpages.currentpage().getparameters().get('pIndex'))));
            Integer startIndex = Integer.valueOf(apexpages.currentpage().getparameters().get('pIndex'));
            for(Integer i = 0; i < createNewSObjectList.Size(); i++) {
                createNewSObjectList[i].iRecNo = i+1;
            }
            isFileUploaded = false;
            rowNumber--;
            return null;
        }

        public PageReference cancelItem() {
            String redirectUrl = (strReturnUrl == null ||strReturnUrl == '') ? ((strSObjectId == null || strSObjectId == '') ? '' : strSObjectId) : strReturnUrl;
            PageReference objPageReference = new pageReference( '/' + redirectUrl);
            objPageReference.setRedirect(true);
            return objPageReference;
        }

        public void displayDeletionMessage() {
            String errorMessage = Apexpages.currentPage().getParameters().get('pErrorMessage');
            ApexPages.Message myMsg = errorMessage.equals('Record Deleted Successfully.') ? new ApexPages.Message(ApexPages.Severity.INFO, errorMessage) : new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(myMsg);
            isSaveMessage = false;
            isDeleterMessage = true;
        }

        public void displayDeleteChildMessage() {
            retrieveChildFieldset(NULL);
            isSaveMessage = false;
            isDeleterMessage = true;
            childDataList = getChildData ();
        }

        public void displayDeleteChildMessage_QuickSave() {
            retrieveChildFieldset(setInsertedchildId);
            isSaveMessage = false;
            isDeleterMessage = true;
        }

        public PageReference exportDetailReport() {
            strHeaderRowValue = NULL;
            for(String strRowHeader : SObjectChildfieldList) {
                if(strHeaderRowValue != NULL) {
                    strHeaderRowValue += ','+ strRowHeader;
                } else {
                    strHeaderRowValue = strRowHeader;
                }
            }
            PageReference nextpage = new PageReference('/apex/ExportChildFieldSetCsv');
            render = 'application/vnd.ms-excel#Insert Child Records.xls';
            return nextpage;
        }

        public Pagereference importCSVFile() {
            try {
                if(csvFileBody != NULL) {
                    csvAsString = csvFileBody.toString();
                    csvFileLines = csvAsString.split('\n');
                    strHeaderRow = csvFileLines[0].split(',');
                    for (Integer i = 1; i < csvFileLines.size(); i++) {
                        String[] inputvalues = new String[] {};
                        inputvalues = csvFileLines[i].split(',');
                        SObject SObjectToInsert = Schema.getGlobalDescribe().get(objSetting.Child_SObject_Name__c).newSObject();
                        for(Integer iField = 0; iField < listChildFieldSetMember.size(); iField++) {
                            if(strHeaderRow[iField].trim().equalsIgnoreCase(listChildFieldSetMember[iField].getFieldPath())) {
                                if(listChildFieldSetMember[iField].getType() == Schema.Displaytype.Double) {
                                    SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Double.valueOf(inputvalues[iField].trim()));
                                } else if(listChildFieldSetMember[iField].getType() == Schema.Displaytype.Integer) {
                                    SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Integer.valueOf(inputvalues[iField].trim()));
                                } else if(listChildFieldSetMember[iField].getType() == Schema.Displaytype.Currency) {
                                    SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Decimal.valueOf(inputvalues[iField].trim()));
                                } else if(listChildFieldSetMember[iField].getType() == Schema.Displaytype.Date) {
                                    try {
                                        SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), date.parse(inputvalues[iField].trim()));
                                    } catch(Exception e) {
                                        isVisible = true;
                                        isSaveMessage = false;
                                        isDeleterMessage = false;
                                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'The column format must be <b> mm/dd/yyyy </b>for the Date field <b>'+listChildFieldSetMember[iField].getFieldPath()+ '</b> in uploaded csv file.');
                                        ApexPages.addMessage(errorMessage);
                                    }
                                } else if(listChildFieldSetMember[iField].getType() == Schema.Displaytype.Datetime) {
                                    try {
                                        SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Datetime.parse(inputvalues[iField].trim()));
                                    } catch(Exception e) {
                                        isVisible = true;
                                        isSaveMessage = false;
                                        isDeleterMessage = false;
                                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'The column format must be <b> mm/dd/yyyy hh:mm AM/PM </b>for the DateTime field <b>'+listChildFieldSetMember[iField].getFieldPath()+ '</b> in uploaded csv file.');
                                        ApexPages.addMessage(errorMessage);
                                    }
                                } else if(listChildFieldSetMember[iField].getType() == Schema.Displaytype.Boolean) {
                                    try {
                                        if(inputvalues[iField].trim().equalsIgnoreCase('Yes')) {
                                            SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Boolean.valueOf('true'));
                                        } else if(inputvalues[iField].trim().equalsIgnoreCase('No')) {
                                            SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Boolean.valueOf('false'));
                                        } else {
                                            SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), Boolean.valueOf(inputvalues[iField].trim()));
                                        }
                                    } catch(Exception e) {
                                        isVisible = true;
                                        isSaveMessage = false;
                                        isDeleterMessage = false;
                                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                                        ApexPages.addMessage(errorMessage);
                                    }
                                } else {
                                    try {
                                        SObjectToInsert.put(listChildFieldSetMember[iField].getFieldPath(), inputvalues[iField].trim());
                                    } catch(Exception e){
                                        isVisible = true;
                                        isSaveMessage = false;
                                        isDeleterMessage = false;
                                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                                        ApexPages.addMessage(errorMessage);
                                    }
                                }
                            }
                        }
                        isFileUploaded = true;
                        if(createNewSObjectList != NULL && createNewSObjectList.size() > 0) {
                            if(rowNumber == 1) {
                                    createNewSObjectList.remove(0);
                            }
                            createNewSObjectList.add(new ChildSObjectWrapper(++rowNumber, SObjectToInsert));
                        }
                        else {
                            createNewSObjectList= new List<ChildSObjectWrapper>();
                            createNewSObjectList.add(new ChildSObjectWrapper(++rowNumber, SObjectToInsert));
                        }
                    }
                    if(rowNumber == 1) {
                        createNewSObjectList.remove(0);
                    }
                    if(createNewSObjectList.size() < 1) {
                        isVisible = true;
                        isSaveMessage = false;
                        isDeleterMessage = false;
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Empty file found.');
                        ApexPages.addMessage(errorMessage);
                    }
                    csvFileBody = NULL;
                } else {
                    isVisible = true;
                    isSaveMessage = false;
                    isDeleterMessage = false;
                    if(!(createNewSObjectList != NULL && createNewSObjectList.size() > 0)) {
                            createNewChildRecord();
                    }
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'No file selected for uploading bulk records!');
                    ApexPages.addMessage(errormsg);
                }
            } catch (Exception e) {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                ApexPages.addMessage(errormsg);
            }
            return null;
        }

        public class ChildSObjectWrapper {

            public Integer iRecNo {get; set; }
            public SObject objCreateSObject {get; set; }

            public ChildSObjectWrapper(Integer pRecNo, SObject pobjCreateSObject){
                iRecNo = pRecNo;
                objCreateSObject = pobjCreateSObject;
            }
        }

        public class ChildSObjectEditWrapper {

            public Boolean editRecord {get; set; }
            public Integer rowIndexNo {get; set; }
            public SObject objChildSObject {get; set; }
        }
}
