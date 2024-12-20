@RestResource(urlMapping='/tout-data-migrate')
global with sharing class ToutDataMigrator {

    static List<String> jobNameList = new List<String>();
    static {
        jobNameList.add('ToutMigratePack2CustomAccount');
        jobNameList.add('ToutMigratePack2CustomContact');
        jobNameList.add('ToutMigratePack2CustomEvent');
        jobNameList.add('ToutMigratePack2CustomLead');
        jobNameList.add('ToutMigratePack2CustomOpportunity');
        jobNameList.add('ToutMigratePack2CustomTask');
    }
    static String[] getQueued(List<String> jobNameList) {
        String[] queued = new List<String>();
        for ( String jobName : jobNameList ) {
            if (jobAmount(jobName) > 0) {
                queued.add(jobName);
            }
        }
        return queued;
    }

    static String[] getNotQueued(Map<String, ID> jobNameIDMap) {
        String[] queued = new List<String>();
        for ( String jobName : jobNameIDMap.keySet() ) {
            if (jobAmount(jobNameIDMap.get(jobName)) != 1) {
                queued.add(jobName);
            }
        }
        return queued;
    }

    static Integer jobAmount(ID jobId) {
        return (Integer)[SELECT COUNT(Id) amount FROM AsyncApexJob WHERE Id = :jobId][0].get('amount');
    }

    static Integer jobAmount(String jobName) {
        return (Integer)[SELECT COUNT(Id) amount FROM AsyncApexJob WHERE ApexClass.Name = :jobName AND JobType = 'BatchApex'][0].get('amount');
    }

    static void composeResponse(Map<String, Object> respBody,
                                RestResponse response,
                                String status,
                                Object details,
                                Object spec,
                                Object message,
                                Object backtrace,
                                Integer statusCode) {
        if (status != null) respBody.put('status', status);
        if (details != null) respBody.put('details', details);
        if (spec != null) respBody.put('spec', spec);
        if (message != null) respBody.put('message', message);
        if (backtrace != null) respBody.put('backtrace', backtrace);
        if (statusCode != null) response.statusCode = statusCode;
    }

    @HttpPost
    global static void doPost(  ) {
        Map<String, Object> respBody = new Map<String, Object>();
        RestResponse response = RestContext.response;

        try {
            String [] alreadyQueuedErrors = getQueued(jobNameList);
            if (alreadyQueuedErrors.size() > 0) {
                composeResponse(respBody, response, 'error', 'Some of Migration jobs was already added to queue. See list of problem classes in backtrace.', alreadyQueuedErrors, null, null, 200);
            } else {
                Map<String, ID> jobNameIDMap = new Map<String, ID>();
                jobNameIDMap.put('ToutMigratePack2CustomAccount', Database.executeBatch(new ToutMigratePack2CustomAccount(), 1000));
                jobNameIDMap.put('ToutMigratePack2CustomContact', Database.executeBatch(new ToutMigratePack2CustomContact(), 1000));
                jobNameIDMap.put('ToutMigratePack2CustomEvent', Database.executeBatch(new ToutMigratePack2CustomEvent(), 1000));
                jobNameIDMap.put('ToutMigratePack2CustomLead', Database.executeBatch(new ToutMigratePack2CustomLead(), 1000));
                jobNameIDMap.put('ToutMigratePack2CustomOpportunity', Database.executeBatch(new ToutMigratePack2CustomOpportunity(), 1000));
                jobNameIDMap.put('ToutMigratePack2CustomTask', Database.executeBatch(new ToutMigratePack2CustomTask(), 1000));

                String [] queueErrors = getNotQueued(jobNameIDMap);
                if (queueErrors.size() > 0) {
                    composeResponse(respBody, response, 'error', 'Some of Migration jobs was not added to queue. See list of problem classes in backtrace.', queueErrors, null, null, 200);
                } else {
                    Long totalAmountOfRows = ToutMigratePack2CustomAccount.batchesCount() +
                                             ToutMigratePack2CustomContact.batchesCount() +
                                             ToutMigratePack2CustomEvent.batchesCount() +
                                             ToutMigratePack2CustomLead.batchesCount() +
                                             ToutMigratePack2CustomOpportunity.batchesCount() +
                                             ToutMigratePack2CustomTask.batchesCount();
                    Map<String, Object> respDetails = new Map<String, Object>();
                    respDetails.put('job_ids', jobNameIDMap.values());
                    respDetails.put('total_rows', totalAmountOfRows);
                    composeResponse(respBody,
                                    response,
                                    'success',
                                    respDetails,
                                    null,
                                    'Migration started successfully.',
                                    null,
                                    202);
                }
            }
        } catch (Exception e) {
            String [] stacktrace = new List<String>();
            stacktrace.add(e.getStackTraceString());
            composeResponse(respBody, response, 'error', e.getMessage(), null, null, stacktrace, 200);
        }
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(respBody));
    }
    @HttpGet
    global static void doGet() {
        RestResponse res = RestContext.response;
        Map<String, Object> respBody = new Map<String, Object>();
        try {
            RestRequest req = RestContext.request;
            Map<String, String> reqBody = req.params;
            Integer totalRows = Integer.valueOf(reqBody.get('total_rows'));
            List<ID> jobIds = (List<ID>)JSON.deserialize(reqBody.get('job_ids'), List<ID>.class);
            List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name, CompletedDate, ExtendedStatus, JobItemsProcessed, JobType, MethodName, NumberOfErrors, Status, TotalJobItems FROM AsyncApexJob WHERE Id IN :jobIds];
            Boolean completed = true;
            Integer processedCount = 0;
            for (AsyncApexJob job: jobs) {
                processedCount = processedCount + job.JobItemsProcessed;
                if (job.Status != 'Completed') {
                    completed = false;
                }
            }
            if (completed == true) {
                respBody.put('status', 'success');
                respBody.put('message', 'Migration completed successfully.');
                respBody.put('state', 'complete');
            } else {
                Double progress = 0;
                if (totalRows > 0) {
                    progress = (processedCount * 100) / totalRows;
                }
                respBody.put('status', 'success');
                respBody.put('message', 'Migration still in progress.');
                respBody.put('state', 'in_progress');
                respBody.put('migration_progress', progress);
            }
            res.statusCode = 200;
        } catch (exception e) {
            String [] stacktrace = new List<String>();
            stacktrace.add(e.getStackTraceString());
            respBody.put('status', 'error');
            respBody.put('details', e.getMessage());
            respBody.put('backtrace', stacktrace);
            res.statusCode = 200;
        }
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(respBody));
    }
}