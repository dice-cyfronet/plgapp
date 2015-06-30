#!/usr/bin/env python
"""plgapp probe.

Usage:
    plgapp_probe.py -H <hostname> -t <timeout> [-d]

Options:
    -H <hostname>       Target host.
    -t <timeout>        Time limit for operations.
    -d                  Print verbose output, not suitable for Nagios operation.

"""
import sys
import httplib
from optparse import OptionParser

# global variables

debug = False
plgapp_url = None
timeout = 200

# helper functions

def return_with(code, msg, details=None):
    print msg
    if details is not None:
        print details
    sys.exit(code)


def return_ok(msg, details=None):
    return_with(0, msg, details)


def return_warning(msg, details=None):
    return_with(1, msg, details)


def return_critical(msg, details=None):
    return_with(2, msg, details)


def return_unknown(msg, details=None):
    return_with(3, msg, details)


def debug_log(text):
    if debug:
        sys.stderr.write(text + '\n')

def make_request(path):
    debug_log("Request: " + plgapp_url + path)

    conn = httplib.HTTPSConnection(plgapp_url)
    if debug:
        conn.set_debuglevel(1)
        
    try:
        conn.request("GET", path)
        # conn.set_debuglevel(1)
        resp = conn.getresponse()
    except Exception, e1:
        return_critical("Unable to do a post request", e1)

    response = resp.read()

    debug_log("Response: " + str(response) + ", code:" + str(resp.status))
    return (response, resp.status)

# testing scenarios

def test_mainpage():
    response, status = make_request('/')
    if status != 200 or 'logo-big' not in response:
        print response
        return_critical('Main page seems down or invalid.')

def test_js_file():
    response, status = make_request('/plgapp/plgapp.js')
    if status != 200 or 'PlgApp base' not in response:
        print response
        return_critical('Plgapp.js seems down or invalid.')

# main function

if __name__ == "__main__":
    parser = OptionParser(version="Plgapp probe v1.0")

    parser.add_option("-H", dest="hostname", metavar="hostname", help="Target host")
    parser.add_option("-t", dest="timeout", metavar="timeout", type="int", default=200, help="Time limit for individual operations")
    parser.add_option("-x", dest="proxy_path", metavar="proxy_path", help="Proxy file location, also can be supplied as X509_USER_PROXY environment variable")
    parser.add_option("-d", action="store_true", dest="debug", help="Print verbose output, not suitable for Nagios operation", default=False)

    (options, args) = parser.parse_args()

    if len(args) != 0:
        return_unknown("Unkown arguments: " + args)

    if options.debug:
        debug = True
    debug_log("options: " + str(options) + ", arguments: " + str(args))

    if not options.hostname:
        return_unknown("Please provide a hostname with -H option")

    plgapp_url = options.hostname

    if options.timeout <= 0:
        return_unknown("Timeout is negative, it needs to be a positive value")

    timeout = options.timeout

    test_mainpage()
    test_js_file()

    return_ok("OK", "Test plan completed without errors")
