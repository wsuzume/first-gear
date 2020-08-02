module Session exposing (Session, Internals, createSession, navKeyOf)

import Browser.Navigation as Nav

type Session
    = Session Internals

type alias Internals =
    { key : Nav.Key
    }

createSession : Nav.Key -> Session
createSession key =
    Session (Internals key)

navKeyOf : Session -> Nav.Key
navKeyOf (Session internals) =
    internals.key
