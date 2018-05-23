module Flags exposing (CSRFToken, Flags, UnAuthedFlags)

import Profile

type alias CSRFToken = String

type alias UnAuthedFlags = {
    csrftoken : CSRFToken }

type alias Flags a = { a |
   csrftoken : CSRFToken
 , profile_id : Profile.ProfileID
 , profile_type : Profile.ProfileType
 , instructor_profile : Maybe Profile.InstructorProfileParams
 , student_profile : Maybe Profile.StudentProfileParams }