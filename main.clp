(defrule is-ok
=>
(printout t "This program can choose status code your server should response with!" crlf)
(printout t "Is everything alright? (yes / no)" crlf)
(assert (is-ok (read))))

    (defrule want-to-redirect
    (is-ok yes)
    =>
    (printout t "Do you want to redirect you user to a new Location? (yes / no)" crlf)
    (assert (want-to-redirect (read))))

    (defrule web-server
    (is-ok yes)
    =>
    (printout t "Are you implementing a web server? (yes / no)" crlf)
    (assert (web-server (read))))


        (defrule r100
        (web-server yes)
        =>
        (printout t "It may be one of 1XX codes depending on what you are doing") crlf)

        (defrule new-location-resource
        (want-to-redirect yes)
        =>
        (printout t "Do you want to redirect to the same resource at a new Location? (yes / no)" crlf)
        (assert (new-location-resource (read))))

            (defrule method-get
            (new-location-resource yes)
            =>
            (printout t "Can the method change to GET? (yes / no)" crlf)
            (assert (method-get (read))))

            (defrule new-location-temporary
            (new-location-resource yes)
            =>
            (printout t "Is the new Location temporary? (yes / no)" crlf)
            (assert (new-location-temporary (read))))

                (defrule r302
                (method-get yes)
                (new-location-temporary yes)
                =>
                (printout t "302 Found") crlf)

                (defrule r301
                (method-get yes)
                (new-location-temporary no)
                =>
                (printout t "301 Moved Permanently") crlf)

                (defrule r307
                (method-get no)
                (new-location-temporary yes)
                =>
                (printout t "307 Temporary Redirect") crlf)

                (defrule r308
                (method-get no)
                (new-location-temporary no)
                =>
                (printout t "308 Permanent Redirect") crlf)

            (defrule new-location-created
            (new-location-resource no)
            =>
            (printout t "Was the location created for the request? (yes / no)" crlf)
            (assert (new-location-created (read))))

                (defrule r201
                (new-location-created yes)
                =>
                (printout t "201 Created") crlf)

                (defrule r303
                (new-location-created no)
                =>
                (printout t "303 See Other") crlf)

        (defrule complete-later
        (want-to-redirect no)
        =>
        (printout t "Will the request be completed later or is it done? (later / done)" crlf)
        (assert (complete-later (read))))

            (defrule r202
            (complete-later later)
            =>
            (printout t "202 Accepted") crlf)

            (defrule dont-change-view
            (complete-later done)
            =>
            (printout t "Do you want the user's view to remain unchanged? (yes / no)" crlf)
            (assert (dont-change-view (read))))

                (defrule r304
                (dont-change-view no)
                (web-server yes)
                =>
                (printout t "304 Not Modified") crlf)

                (defrule r206
                (dont-change-view no)
                (web-server yes)
                =>
                (printout t "206 Partial Content") crlf)

                (defrule r200
                (dont-change-view no)
                =>
                (printout t "200 OK") crlf)

(defrule problem-side
(is-ok no)
=>
(printout t "Is it a problem with request, or is it server-side? (request / server)" crlf)
(assert (problem-side (read))))

    (defrule throttled
    (problem-side request)
    =>
    (printout t "Is the user being throttled? (yes / no)" crlf)
    (assert (throttled (read))))

        (defrule r429
        (throttled yes)
        =>
        (printout t "429 Too Many Requests") crlf)

        (defrule user-needs-auth
        (throttled no)
        =>
        (printout t "Does the user needs authentification? (yes / no)" crlf)
        (assert (user-needs-auth (read))))

            (defrule http-auth
            (user-needs-auth yes)
            =>
            (printout t "Are you using HTTP auth?" crlf)
            (assert (http-auth (read))))

                (defrule r401
                (http-auth yes)
                =>
                (printout t "401 Unauthorized") crlf)

                (defrule to-is-secret-1
                (http-auth no)
                =>
                (printout t "Is resource secret? (yes / no)" crlf)
                (assert (to-is-secret-1 (read))))

                    (defrule r403-1
                    (to-is-secret-1 yes)
                    =>
                    (printout t "403 Forbidden") crlf)

                    (defrule r404-1
                    (to-is-secret-1 no)
                    =>
                    (printout t "404 Not Found") crlf)

            (defrule access-to-resource
            (user-needs-auth no)
            =>
            (printout t "Does the user have access to the resource? (yes / no)" crlf)
            (assert (access-to-resource (read))))

                (defrule to-is-secret-2
                (access-to-resource no)
                =>
                (printout t "Is resource secret? (yes / no)" crlf)
                (assert (to-is-secret-2 (read))))

                    (defrule r403-2
                    (to-is-secret-2 yes)
                    =>
                    (printout t "403 Forbidden") crlf)

                    (defrule r404-2
                    (to-is-secret-1 no)
                    =>
                    (printout t "404 Not Found") crlf)

                (defrule resource-exists
                (access-to-resource yes)
                =>
                (printout t "Does the resource even exist? (yes / no)" crlf)
                (assert (resource-exists (read))))

                    (defrule r404-3
                    (resource-exists no)
                    =>
                    (printout t "404 Not Found") crlf)

                    (defrule handled
                    (resource-exists yes)
                    =>
                    (printout t "Is HTTP method handled by the resource? (yes / no)" crlf)
                    (assert (handled (read))))

                        (defrule r405
                        (handled no)
                        =>
                        (printout t "405 Method Not Allowed") crlf)

                        (defrule header-problem
                        (handled yes)
                        =>
                        (printout t "Problem with the headers? (yes / no)" crlf)
                        (assert (header-problem (read))))

                            (defrule header
                            (header-problem yes)
                            =>
                            (printout t "What is wrong? (Accept / Content-Length / If / Content-Type / other)" crlf)
                            (assert (header (read))))

                                (defrule r406
                                (header Accept)
                                =>
                                (printout t "406 Not Acceptable") crlf)

                                (defrule r411
                                (header Content-Length)
                                =>
                                (printout t "411 Length Required") crlf)

                                (defrule r412
                                (header If)
                                =>
                                (printout t "412 Precondition Failed") crlf)

                                (defrule r415
                                (header Content-Type)
                                =>
                                (printout t "415 Unsupported Media Type") crlf)

                                (defrule r400-1
                                (header other)
                                =>
                                (printout t "400 Bad Request") crlf)

                            (defrule incompatible-with-prev
                            (header-problem no)
                            =>
                            (printout t "Request incompatible with a previous request? (yes/ no)" crlf)
                            (assert (incompatible-with-prev (read))))

                                (defrule r409
                                (incompatible-with-prev yes)
                                =>
                                (printout t "409 conflict") crlf)

                                (defrule r400-2
                                (incompatible-with-prev yes)
                                =>
                                (printout t "400 Bad Request") crlf)

    (defrule retry
    (problem-side server)
    =>
    (printout t "Should user retry? (yes / no)" crlf)
    (assert (retry (read))))

        (defrule r503
        (retry yes)
        =>
        (printout t "503 Service Unavailable") crlf)

        (defrule another-server-problem
        (retry no)
        =>
        (printout t "Is it a problem with another server? (yes / no)" crlf)
        (assert (another-server-problem (read))))

            (defrule another-server-responds
            (another-server-problem yes)
            =>
            (printout t "Is the other server responding? (yes / no)" crlf)
            (assert (another-server-responds (read))))

                (defrule r502
                (another-server-responds yes)
                =>
                (printout t "502 Bad Gateway") crlf)

                (defrule r504
                (another-server-responds no)
                =>
                (printout t "504 Gateway Timeout") crlf)

            (defrule guilty
            (another-server-problem no)
            =>
            (printout t "Do you feel guilty? (yes / no)" crlf)
            (assert (guilty (read))))

                (defrule r501
                (guilty yes)
                =>
                (printout t "501 Not Implemented") crlf)

                (defrule r500
                (guilty no)
                =>
                (printout t "500 Internal Server Error") crlf)
