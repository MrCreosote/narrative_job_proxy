package Bio::KBase::narrativejobproxy::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::narrativejobproxy::Client

=head1 DESCRIPTION


Very simple proxy that reauthenticates requests to the user_and_job_state
service as the narrative user


=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'http://localhost:7068';
    }

    my $self = {
	client => Bio::KBase::narrativejobproxy::Client::RpcClient->new,
	url => $url,
    };

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 ver

  $ver = $obj->ver()

=over 4

=item Parameter and return types

=begin html

<pre>
$ver is a string

</pre>

=end html

=begin text

$ver is a string


=end text

=item Description

Returns the version of the narrative_job_proxy service.

=back

=cut

sub ver
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function ver (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "NarrativeJobProxy.ver",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'ver',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method ver",
					    status_line => $self->{client}->status_line,
					    method_name => 'ver',
				       );
    }
}



=head2 get_detailed_error

  $error = $obj->get_detailed_error($job)

=over 4

=item Parameter and return types

=begin html

<pre>
$job is a NarrativeJobProxy.job_id
$error is a NarrativeJobProxy.detailed_err
job_id is a string
detailed_err is a string

</pre>

=end html

=begin text

$job is a NarrativeJobProxy.job_id
$error is a NarrativeJobProxy.detailed_err
job_id is a string
detailed_err is a string


=end text

=item Description

Get the detailed error message, if any

=back

=cut

sub get_detailed_error
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_detailed_error (received $n, expecting 1)");
    }
    {
	my($job) = @args;

	my @_bad_arguments;
        (!ref($job)) or push(@_bad_arguments, "Invalid type for argument 1 \"job\" (value was \"$job\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_detailed_error:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_detailed_error');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "NarrativeJobProxy.get_detailed_error",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_detailed_error',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_detailed_error",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_detailed_error',
				       );
    }
}



=head2 get_job_info

  $info = $obj->get_job_info($job)

=over 4

=item Parameter and return types

=begin html

<pre>
$job is a NarrativeJobProxy.job_id
$info is a NarrativeJobProxy.job_info
job_id is a string
job_info is a reference to a list containing 14 items:
	0: (job) a NarrativeJobProxy.job_id
	1: (service) a NarrativeJobProxy.service_name
	2: (stage) a NarrativeJobProxy.job_stage
	3: (started) a NarrativeJobProxy.timestamp
	4: (status) a NarrativeJobProxy.job_status
	5: (last_update) a NarrativeJobProxy.timestamp
	6: (prog) a NarrativeJobProxy.total_progress
	7: (max) a NarrativeJobProxy.max_progress
	8: (ptype) a NarrativeJobProxy.progress_type
	9: (est_complete) a NarrativeJobProxy.timestamp
	10: (complete) a NarrativeJobProxy.boolean
	11: (error) a NarrativeJobProxy.boolean
	12: (desc) a NarrativeJobProxy.job_description
	13: (res) a NarrativeJobProxy.Results
service_name is a string
job_stage is a string
timestamp is a string
job_status is a string
total_progress is an int
max_progress is an int
progress_type is a string
boolean is an int
job_description is a string
Results is a reference to a hash where the following keys are defined:
	shocknodes has a value which is a reference to a list where each element is a string
	shockurl has a value which is a string
	workspaceids has a value which is a reference to a list where each element is a string
	workspaceurl has a value which is a string
	results has a value which is a reference to a list where each element is a NarrativeJobProxy.Result
Result is a reference to a hash where the following keys are defined:
	server_type has a value which is a string
	url has a value which is a string
	id has a value which is a string
	description has a value which is a string

</pre>

=end html

=begin text

$job is a NarrativeJobProxy.job_id
$info is a NarrativeJobProxy.job_info
job_id is a string
job_info is a reference to a list containing 14 items:
	0: (job) a NarrativeJobProxy.job_id
	1: (service) a NarrativeJobProxy.service_name
	2: (stage) a NarrativeJobProxy.job_stage
	3: (started) a NarrativeJobProxy.timestamp
	4: (status) a NarrativeJobProxy.job_status
	5: (last_update) a NarrativeJobProxy.timestamp
	6: (prog) a NarrativeJobProxy.total_progress
	7: (max) a NarrativeJobProxy.max_progress
	8: (ptype) a NarrativeJobProxy.progress_type
	9: (est_complete) a NarrativeJobProxy.timestamp
	10: (complete) a NarrativeJobProxy.boolean
	11: (error) a NarrativeJobProxy.boolean
	12: (desc) a NarrativeJobProxy.job_description
	13: (res) a NarrativeJobProxy.Results
service_name is a string
job_stage is a string
timestamp is a string
job_status is a string
total_progress is an int
max_progress is an int
progress_type is a string
boolean is an int
job_description is a string
Results is a reference to a hash where the following keys are defined:
	shocknodes has a value which is a reference to a list where each element is a string
	shockurl has a value which is a string
	workspaceids has a value which is a reference to a list where each element is a string
	workspaceurl has a value which is a string
	results has a value which is a reference to a list where each element is a NarrativeJobProxy.Result
Result is a reference to a hash where the following keys are defined:
	server_type has a value which is a string
	url has a value which is a string
	id has a value which is a string
	description has a value which is a string


=end text

=item Description

Get information about a job.

=back

=cut

sub get_job_info
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_job_info (received $n, expecting 1)");
    }
    {
	my($job) = @args;

	my @_bad_arguments;
        (!ref($job)) or push(@_bad_arguments, "Invalid type for argument 1 \"job\" (value was \"$job\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_job_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_job_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "NarrativeJobProxy.get_job_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_job_info',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_job_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_job_info',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "NarrativeJobProxy.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_job_info',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_job_info",
            status_line => $self->{client}->status_line,
            method_name => 'get_job_info',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::narrativejobproxy::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::narrativejobproxy::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

A boolean. 0 = false, other = true.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 service_name

=over 4



=item Description

A service name.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 timestamp

=over 4



=item Description

A time in the format YYYY-MM-DDThh:mm:ssZ, where Z is the difference
in time to UTC in the format +/-HHMM, eg:
        2012-12-17T23:24:06-0500 (EST time)
        2013-04-03T08:56:32+0000 (UTC time)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 job_id

=over 4



=item Description

A job id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 job_stage

=over 4



=item Description

A string that describes the stage of processing of the job.
One of 'created', 'started', 'completed', or 'error'.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 job_status

=over 4



=item Description

A job status string supplied by the reporting service.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 job_description

=over 4



=item Description

A job description string supplied by the reporting service.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 detailed_err

=over 4



=item Description

Detailed information about a job error, such as a stacktrace, that will
not fit in the job_status. No more than 100K characters.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 total_progress

=over 4



=item Description

The total progress of a job.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 max_progress

=over 4



=item Description

The maximum possible progress of a job.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 progress_type

=over 4



=item Description

The type of progress that is being tracked. One of:
'none' - no numerical progress tracking
'task' - Task based tracking, e.g. 3/24
'percent' - percentage based tracking, e.g. 5/100%


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Result

=over 4



=item Description

A place where the results of a job may be found.
All fields except description are required.

string server_type - the type of server storing the results. Typically
        either "Shock" or "Workspace". No more than 100 characters.
string url - the url of the server. No more than 1000 characters.
string id - the id of the result in the server. Typically either a
        workspace id or a shock node. No more than 1000 characters.
string description - a free text description of the result.
         No more than 1000 characters.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
server_type has a value which is a string
url has a value which is a string
id has a value which is a string
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
server_type has a value which is a string
url has a value which is a string
id has a value which is a string
description has a value which is a string


=end text

=back



=head2 Results

=over 4



=item Description

A pointer to job results. All arguments are optional. Applications
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


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
shocknodes has a value which is a reference to a list where each element is a string
shockurl has a value which is a string
workspaceids has a value which is a reference to a list where each element is a string
workspaceurl has a value which is a string
results has a value which is a reference to a list where each element is a NarrativeJobProxy.Result

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
shocknodes has a value which is a reference to a list where each element is a string
shockurl has a value which is a string
workspaceids has a value which is a reference to a list where each element is a string
workspaceurl has a value which is a string
results has a value which is a reference to a list where each element is a NarrativeJobProxy.Result


=end text

=back



=head2 job_info

=over 4



=item Description

Information about a job.


=item Definition

=begin html

<pre>
a reference to a list containing 14 items:
0: (job) a NarrativeJobProxy.job_id
1: (service) a NarrativeJobProxy.service_name
2: (stage) a NarrativeJobProxy.job_stage
3: (started) a NarrativeJobProxy.timestamp
4: (status) a NarrativeJobProxy.job_status
5: (last_update) a NarrativeJobProxy.timestamp
6: (prog) a NarrativeJobProxy.total_progress
7: (max) a NarrativeJobProxy.max_progress
8: (ptype) a NarrativeJobProxy.progress_type
9: (est_complete) a NarrativeJobProxy.timestamp
10: (complete) a NarrativeJobProxy.boolean
11: (error) a NarrativeJobProxy.boolean
12: (desc) a NarrativeJobProxy.job_description
13: (res) a NarrativeJobProxy.Results

</pre>

=end html

=begin text

a reference to a list containing 14 items:
0: (job) a NarrativeJobProxy.job_id
1: (service) a NarrativeJobProxy.service_name
2: (stage) a NarrativeJobProxy.job_stage
3: (started) a NarrativeJobProxy.timestamp
4: (status) a NarrativeJobProxy.job_status
5: (last_update) a NarrativeJobProxy.timestamp
6: (prog) a NarrativeJobProxy.total_progress
7: (max) a NarrativeJobProxy.max_progress
8: (ptype) a NarrativeJobProxy.progress_type
9: (est_complete) a NarrativeJobProxy.timestamp
10: (complete) a NarrativeJobProxy.boolean
11: (error) a NarrativeJobProxy.boolean
12: (desc) a NarrativeJobProxy.job_description
13: (res) a NarrativeJobProxy.Results


=end text

=back



=cut

package Bio::KBase::narrativejobproxy::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
