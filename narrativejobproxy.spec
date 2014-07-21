/* 
Very simple proxy that reauthenticates requests to the user_and_job_state
service as the narrative user

*/

module NarrativeJobProxy {

	/*
		Returns the version of the narrative_job_proxy service.
	*/
	funcdef ver() returns(string ver);

	/* All other calls require authentication. */
	authentication required;
	
	/* A boolean. 0 = false, other = true. */
	typedef int boolean;
	
	/* A service name. */
	typedef string service_name;
	
	/* 
		A time in the format YYYY-MM-DDThh:mm:ssZ, where Z is the difference
		in time to UTC in the format +/-HHMM, eg:
			2012-12-17T23:24:06-0500 (EST time)
			2013-04-03T08:56:32+0000 (UTC time)
	*/
	typedef string timestamp;
		
	/* A job id. */
	typedef string job_id;
	
	/* A string that describes the stage of processing of the job.
		One of 'created', 'started', 'completed', or 'error'.
	*/
	typedef string job_stage;
	
	/* A job status string supplied by the reporting service.
	*/
	typedef string job_status;
	
	/* A job description string supplied by the reporting service.
	*/
	typedef string job_description;
	
	/* Detailed information about a job error, such as a stacktrace, that will
		not fit in the job_status. No more than 100K characters.
	*/
	typedef string detailed_err;
	
	/* The total progress of a job. */
	typedef int total_progress;
	
	/* The maximum possible progress of a job. */
	typedef int max_progress;
	
	/* The type of progress that is being tracked. One of:
		'none' - no numerical progress tracking
		'task' - Task based tracking, e.g. 3/24
		'percent' - percentage based tracking, e.g. 5/100%
	*/ 
	typedef string progress_type;
	
	/* A place where the results of a job may be found.
		All fields except description are required.
		
		string server_type - the type of server storing the results. Typically
			either "Shock" or "Workspace". No more than 100 characters.
		string url - the url of the server. No more than 1000 characters.
		string id - the id of the result in the server. Typically either a
			workspace id or a shock node. No more than 1000 characters.
		string description - a free text description of the result.
			 No more than 1000 characters.
	*/
	typedef structure {
		string server_type;
		string url;
		string id;
		string description;
	} Result;
	
	/* A pointer to job results. All arguments are optional. Applications
		should use the default shock and workspace urls if omitted.
		list<string> shocknodes - the shocknode(s) where the results can be
			found. No more than 1000 characters.
		string shockurl - the url of the shock service where the data was
			saved.  No more than 1000 characters.
		list<string> workspaceids - the workspace ids where the results can be
			found. No more than 1000 characters.
		string workspaceurl - the url of the workspace service where the data
			was saved.  No more than 1000 characters.
		list<Result> - a set of job results. This format allows for specifying
			results at multiple server locations and providing a free text
			description of the result.
	*/
	typedef structure {
		list<string> shocknodes;
		string shockurl;
		list<string> workspaceids;
		string workspaceurl;
		list<Result> results;
	} Results;
		
	/* Get the detailed error message, if any */
	funcdef get_detailed_error(job_id job) returns(detailed_err error);
	
	/* Information about a job. */
	typedef tuple<job_id job, service_name service, job_stage stage,
		timestamp started, job_status status, timestamp last_update,
		total_progress prog, max_progress max, progress_type ptype,
		timestamp est_complete, boolean complete, boolean error,
		job_description desc, Results res> job_info;
	
	/* Get information about a job. */
	funcdef get_job_info(job_id job) returns(job_info info);
};