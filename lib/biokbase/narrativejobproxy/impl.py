#BEGIN_HEADER
#END_HEADER


class NarrativeJobProxy:
    '''
    Module Name:
    NarrativeJobProxy

    Module Description:
    Very simple proxy that reauthenticates requests to the user_and_job_state
service as the narrative user
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        #END_CONSTRUCTOR
        pass

    def ver(self):
        # self.ctx is set by the wsgi application class
        # return variables are: ver
        #BEGIN ver
        #END ver

        #At some point might do deeper type checking...
        if not isinstance(ver, basestring):
            raise ValueError('Method ver return value ' +
                             'ver is not type basestring as required.')
        # return the results
        return [ver]

    def get_detailed_error(self, job):
        # self.ctx is set by the wsgi application class
        # return variables are: error
        #BEGIN get_detailed_error
        #END get_detailed_error

        #At some point might do deeper type checking...
        if not isinstance(error, basestring):
            raise ValueError('Method get_detailed_error return value ' +
                             'error is not type basestring as required.')
        # return the results
        return [error]

    def get_job_info(self, job):
        # self.ctx is set by the wsgi application class
        # return variables are: info
        #BEGIN get_job_info
        #END get_job_info

        #At some point might do deeper type checking...
        if not isinstance(info, list):
            raise ValueError('Method get_job_info return value ' +
                             'info is not type list as required.')
        # return the results
        return [info]
