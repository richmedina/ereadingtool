module Pages.Guide.Priority exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
-- import Html.Attributes exposing (alt, attribute, class, href, id, placeholder, src, style, title, value)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Markdown
import Session exposing (Session)
import Shared
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Question.Model exposing (Question)


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



type alias Model =
    { activities : Dict String Activity }


type alias Answer =
    { answer : String 
    , correct : Bool
    , selected : Bool
    }

-- DICT METHOD

-- type alias Question =
--     { question : String
--     , answers : List Answer
--     }

-- type alias Activity =
--     { activity : String
--     , questions : List Question
--     }

-- Activities : Dict String Activity
-- Activities =
--     Dict.fromList
--         [ ("firstActivity")
--         ]

-- Questions : Dict String Question
-- Questions =
--     Dict.fromList
--         [ ("firstQuestion" get "firstQuestion" Answers)]

-- Answers : Dict String Answer
-- Answers =
--     Dict.fromList
--         [ ("firstAnswer", "asdf", True, False)]


-- CUSTOM TYPES
type Activity
    = Activity (Dict String Question)

type Question
    = Question (Dict String Answer)


questions : Activity -> Dict String Question
questions (Activity qs) =
    qs

answers : Question -> Dict String Answer
answers (Question ans) =
    ans


-- checkAnswer takes question
-- returns correct answer or not? 
-- foldl??? with condition that both must be true, if end result is True, they answered correctly
-- feedback blobs will need to have a hidden flag showResults
-- model has showResults, when flipped to true calculate results, default showResults... '' ? rendered and hidden OR Maybe Answer

--     showResults last!! 

-- INIT


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { activities = initHelper }
    , Cmd.none
    )           


initHelper : Dict String Activity
initHelper =
    Dict.fromList []
    -- [ 
        -- Activity { label = "Activity1" 
        --          , questions = [ Question  {
        --             label = "Question1"
        --             , answers = [ Answer "Answer1" True False
        --               , Answer "Answer2" False False
        --             ]
        --          }
        -- ] }
    -- ]
    -- [
    --     { "Activity1" :
    --         { "Question1" :
    --             {
    --                 "Answer1" :
    --                     {
    --                         "answer" : "some answer"
    --                         , "correct" : True
    --                         , "checked" : False
    --                     }
    --                 , "Answer2" : 
    --                     {
    --                         "answer" : "another answer"
    --                         , "correct" : False
    --                         , "checked" : False
    --                     }
    --             }
    --         }
    --     }
    -- ]


-- UPDATE


type Msg
    = UpdateAnswer String String String
    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAnswer activity question answer ->
            let
                -- reuse the drill down for simply getting their answer to return
                maybeActivity = Maybe.map identity (Dict.get activity model.activities)

                maybeQuestion = case maybeActivity of
                    -- Just activity -> Maybe.map identity (Dict.get q maybeActivity)
                    Just ac -> Maybe.map identity (Dict.get question (questions ac))
                    Nothing -> Maybe.map identity Nothing

                maybeAnswer = case maybeQuestion of
                    -- Just question -> Maybe.map identity (Dict.get an maybeQuestion)
                    Just q -> Maybe.map identity (Dict.get answer (answers q))
                    Nothing -> Maybe.map identity Nothing

                updatedAnswer = case maybeAnswer of
                --    Just a -> { a | selected = not selected }
                --    Just an -> Answer ({ an | selected = not an.selected })
                   Just an -> Answer an.answer an.correct (not an.selected)
                   Nothing -> Answer "" False False

                updatedQuestion = case maybeQuestion of
                    Just q -> Question (Dict.update answer (Maybe.map (\_ -> updatedAnswer)) (answers q))
                    Nothing -> Question (Dict.fromList [])

                updatedActivity = case maybeActivity of
                    -- Just activity -> Dict.update q (Maybe.map (\_ -> updatedQuestion)) activity
                    Just ac -> Activity (Dict.update question (Maybe.map (\_ -> updatedQuestion)) (questions ac))
                    Nothing -> Activity (Dict.fromList [])


            in
            -- ( case updatedActivity of
            --     Just ac -> { model | activities = Dict.update ac (\_ -> updatedActivity) model.activities }
            --     Nothing -> model
            ( { model | activities = Dict.update activity (Maybe.map (\_ -> updatedActivity)) model.activities }
            , Cmd.none
            )

-- updateActivity : Model -> String -> String -> String -> Model
-- updateActivity model activity question answer = 
--     -- case 
--     { model | activities = Dict.update activity (Maybe.map (updateQuestion question answer)) model.activities }


-- updateQuestion : String -> String -> Dict String Question -> Dict String Question
-- updateQuestion q a qs =
--     -- Dict.update "question1" (Maybe.map (a function that updates an answer in the dict of answers -> returns the value accessed by the key "answer1")) qs
--     Dict.update q (Maybe.map updateAnswer a) qs


-- updateAnswer : String -> String -> Dict String Answer
-- updateAnswer an ans =
--     -- Dict.update "answer1" (Maybe.map (a function that updates the checked field of the record accessed by "answer1" -> return the value accessed by "answer1")) ans
--     Dict.update an (\a -> Maybe.map updateAnswerCheckedField a) ans

-- updateAnswerCheckedField : Answer -> Answer
-- updateAnswerCheckedField an =
--     { an | selected = not an.selected }


-- VIEW


type alias Params =
    ()


view : Model -> Document Msg
view model =
    { title = "Guide | Priority"
    , body =
        [ div [ id "body" ]
            [ div [ id "about" ]
                [ div [ id "about-box" ]
                    [ div [ id "title" ] [ text "Priority" ]
                    , viewTabs
                    , viewFirstQuestion model
                    , viewFirstSection
                    , viewSecondSection
                    , viewThirdSection
                    , viewFourthSection
                    , viewFifthSection
                    , viewSixthSection
                    , viewSeventhSection
                    ]
                ]
            ]
        ]
    }

-- DICT METHOD
-- viewFirstQuestion : Model -> Html Msg
-- viewFirstQuestion model =
--     let 

--     in
--     div [] [
--         Html.form [] [
--             input [ type_ "radio", name "activity_1", id "first", onClick (UpdateAnswer firstActivity firstQuestion firstAnswer )] []
--             , label [for "first"] [ text "first"]
--             , input [ type_ "radio", name "activity_1", id "second", onClick (UpdateAnswer firstActivity firstQuestion secondAnswer ) ] []
--             , label [for "second"] [ text "second"]
--         ]
--     ]

-- CUSTOM TYPES
viewFirstQuestion : Model -> Html Msg
viewFirstQuestion model =
    div [] [
        Html.form [] [
            -- input [ type_ "radio", name "activity_1", id "first", onClick (UpdateAnswer firstActivity firstQuestion firstAnswer )] []
            input [ type_ "radio", name "activity_1", id "first", onClick (UpdateAnswer "Activity1" "Question1" "Answer1" )] []
            , label [for "first"] [ text "first"]
            -- , input [ type_ "radio", name "activity_1", id "second", onClick (UpdateAnswer firstActivity firstQuestion secondAnswer ) ] []
            -- , label [for "second"] [ text "second"]
        ]
    ]

-- function that generates a activity

-- function that generates a question

-- function that generates an answer

viewTabs : Html Msg
viewTabs =
    div [ class "guide-tabs" ]
        [ div
            [ class "guide-tab"
            , class "leftmost-guide-tab"
            ]
            [ a
                [ href (Route.toString Route.Guide__GettingStarted)
                , class "guide-link"
                ]
                [ text "Getting Started" ]
            ]
        , div
            [ class "guide-tab"
            ]
            [ a
                [ href (Route.toString Route.Guide__ReadingTexts)
                , class "guide-link"
                ]
                [ text "Reading Texts" ]
            ]
        , div
            [ class "guide-tab"
            ]
            [ a
                [ href (Route.toString Route.Guide__Settings)
                , class "guide-link"
                ]
                [ text "Settings" ]
            ]
        , div
            [ class "guide-tab"
            ]
            [ a
                [ href (Route.toString Route.Guide__Progress)
                , class "guide-link"
                ]
                [ text "Progress" ]
            ]
        , div [ class "guide-tab" 
            , class "selected-guide-tab"
            ]
            [ a
                [ href (Route.toString Route.Guide__Strategies)
                , class "guide-link"
                ]
                [ text "Strategies" ]
            ]
        , div [ class "guide-tab" 
            ]
            [ a
                [ href (Route.toString Route.Guide__Comprehension)
                , class "guide-link"
                ]
                [ text "Comprehension" ]
            ]
        , div [ class "guide-tab" 
            ]
            [ a
                [ href (Route.toString Route.Guide__Context)
                , class "guide-link"
                ]
                [ text "Context" ]
            ]
        , div [ class "guide-tab" 
            , class "selected-guide-tab"
            ]
            [ a
                [ href (Route.toString Route.Guide__Priority)
                , class "guide-link"
                ]
                [ text "Priority" ]
            ]
        ]


viewFirstSection : Html Msg
viewFirstSection =
    Markdown.toHtml [ attribute "class" "markdown-link" ] """
### Prioritizing words

It is usually not practical to try to look up every word that you don’t know in a text. It can take far too much time, and the process of looking 
may distract you from trying to get any meaning out of what you do understand. So, you need to develop a sense of what words to prioritize for looking up. 


1. **Notice the frequency of unfamiliar words**
The first thing to prioritize are unknown words that appear multiple times in a text or passage. Understanding repeated words will help you stretch your understanding of the text.
"""


viewSecondSection : Html Msg
viewSecondSection =
    div [class "sample-passage"] [
        Html.em [] [ Html.text  "A Boat on the River"]
        , Html.br [] []
        , Html.br [] []
        , Html.text """
        The gapels in this boat were those of a foslaint man with nabelked amboned hair and a trathmollated face, and a finlact girl of nineteen or twenty, 
        nabbastly like him to be sorbicable as his """
        , Html.strong [] [ Html.text "fornoy" ]
        , Html.text """. The girl zarred, pulling a pair of sculls very easily; the man, with the rudder-lines slack in 
        his dispers, and his dispers loose in his waistband, kept an eager look out. He had no net, galeaft, or line, and he could not be a paplil; his boat 
        had no """
        , Html.strong [] [ Html.text "exbain" ]
        , Html.text """ for a sitter, no paint, no debilk, no bepult beyond a rusty calben and a lanop of rope, and he could not be a waterman; his boat was too 
        anem and too divey to take in besder for delivery, and he could not be a river-carrier; there was no paff to what he looked for, sar he looked for 
        something, with a most nagril and searching profar. The befin, which had turned an hour before, was melucting zopt, and his eyes """
        , Html.strong [] [ Html.text "hasteled" ]
        , Html.text " every little furan and gaist in its broad sweep, as the boat made bilp ducasp against it, or drove stern foremost before it, according as he calbained his "
        , Html.strong [] [ Html.text "fornoy" ]
        , Html.text " by a "
        , Html.strong [] [ Html.text "calput" ]
        , Html.text " of his head. She "
        , Html.strong [] [ Html.text "hasteled" ]
        , Html.text " his face as parnly as he "
        , Html.strong [] [ Html.text "hasteled" ]
        , Html.text " the river. But, in the astortant of her look there was a touch of bazad or fisd."
    ]


viewThirdSection : Html Msg
viewThirdSection =
    Markdown.toHtml [] """
### Prioritize words to look up strategically
What next to prioritize will depend on what your motivation for reading is. If you’re trying to follow the basic plot of a story, then look up nouns and verbs, so you know where, when, 
who and what. If you’re trying to understand a character, then look up adjectives and phrases that are applied to that character. If you are trying to follow motivations of characters, then 
looking up words in the clause that starts with the word “because….” might be most helpful. If you are reading a text for class, the comprehension questions your teacher has assigned can help 
you prioritize what parts of the text you need to focus on.

#### Unfamiliar words and their part of speech
Part of prioritizing what words to look up is recognizing or having a strong sense as to the part of speech of the unfamiliar word. Using the grammar of the surrounding text, you can often 
tell an unfamiliar word’s part of speech. The nonsense words in this text also all use regular English grammatical endings, so those can help you as well. Be sure to determine the part of 
speech based on how the word is used in the sentence and not just on its grammatical ending.
"""



viewFourthSection : Html Msg
viewFourthSection =
    div [class "sample-passage"] [
        Html.em [] [ Html.text  "A Boat on the River"]
        , Html.br [] []
        , Html.br [] []
        , Html.text "The gapels in this boat were those of a foslaint man with nabelked amboned hair and a "
        , Html.strong [] [ Html.text "trathmollated" ]
        , Html.text " face, and a finlact girl of nineteen or twenty, nabbastly like him to be sorbicable as his fornoy. The girl "
        , Html.strong [] [ Html.text "zarred" ]
        , Html.text """, pulling a pair of sculls very easily; the man, with the rudder-lines slack in his dispers, and his dispers loose in his waistband, 
        kept an eager look out. He had no net, galeaft, or line, and he could not be a """
        , Html.strong [] [ Html.text "paplil" ]
        , Html.text """; his boat had no exbain for a sitter, no paint, no debilk, no bepult beyond a rusty calben and a lanop of rope, and he could not be a waterman; his boat was too 
        anem and too divey to take in besder for delivery, and he could not be a river-carrier; there was no paff to what he looked for, """
        , Html.strong [] [ Html.text "sar" ]
        , Html.text " he looked for something, with a most "
        , Html.strong [] [ Html.text "nagril" ]
        , Html.text """ and searching profar. The befin, which had turned an hour before, was melucting zopt, and his eyes hasteled every little 
        furan and gaist in its broad sweep, as the boat made bilp ducasp against it, or drove stern foremost before it, according as he calbained his fornoy by 
        a calput of his head. She hasteled his face as """
        , Html.strong [] [ Html.text "parnly" ]
        , Html.text " as he hasteled the river. But, in the astortant of her look there was a touch of bazad or fisd."
    ]


viewFifthSection : Html Msg
viewFifthSection =
    Markdown.toHtml [] """
### Unfamiliar words and their importance to your tasks

If you are reading a text for class, the comprehension questions your teacher has assigned can help you prioritize what parts of the text you need to focus on. For example, your teacher 
included a question that asked about the emotional relationship between the man and the girl in the boat. You will need to locate the part of the text that contains that information, and to 
prioritize those descriptive words that will help you understand that relationship.
"""


viewSixthSection : Html Msg
viewSixthSection =
    div [class "sample-passage"] [
        Html.em [] [ Html.text  "A Boat on the River"]
        , Html.br [] []
        , Html.br [] []
        , Html.text "The gapels in this boat were those of a "
        , Html.strong [] [ Html.text "foslaint" ]
        , Html.text " man with nabelked amboned hair and a trathmollated face, and a finlact girl of nineteen or twenty, nabbastly like him to be sorbicable as his "
        , Html.strong [] [ Html.text "fornoy" ]
        , Html.text """. The girl zarred, pulling a pair of sculls very easily; the man, with the rudder-lines slack in 
        his dispers, and his dispers loose in his waistband, kept an eager look out. He had no net, galeaft, or line, and he could not be a paplil; his boat 
        had no exbain for a sitter, no paint, no debilk, no bepult beyond a rusty calben and a lanop of rope, and he could not be a waterman; his boat was too 
        anem and too """
        , Html.strong [] [ Html.text "divey" ]
        , Html.text """ to take in besder for delivery, and he could not be a river-carrier; there was no paff to what he looked for, sar he looked for 
        something, with a most nagril and searching profar. The befin, which had turned an hour before, was melucting zopt, and his eyes hasteled every little 
        furan and gaist in its broad sweep, as the boat made bilp ducasp against it, or drove stern foremost before it, according as he """
        , Html.strong [] [ Html.text "calbained" ]
        , Html.text " his "
        , Html.strong [] [ Html.text "fornoy" ]
        , Html.text " by a calput of his head. She hasteled his face as parnly as he hasteled the river. But, in the astortant of her look there was a touch of "
        , Html.strong [] [ Html.text "bazad" ]
        , Html.text " or "
        , Html.strong [] [ Html.text "fisd" ]
        , Html.text "."
    ]


viewSeventhSection : Html Msg
viewSeventhSection =
    Markdown.toHtml [] """
#### When looking up words
Once you’ve prioritized a word for look up, be sure you make a guess about its English equivalent before you actually look it up. If your guess is right (or a very close synonym to the right answer), 
then you are probably understanding the passage well.  If your guess is very far from the right answer, be sure to re-read the passage to understand how that changes your sense of what the passage is 
about. If your guess is very far from the answer you find, check to make certain that the word doesn't have other meanings that might fight the context. There aren't an enormous number of homonyms in 
Russian, but many Russian words can be used in different senses or contexts. Be sure that you've got the right sense for your context.

#### Homonyms
Homonyms to look out for:

есть -- can be an infinitive "to eat," and it can be the third person of the verb быть meaning "there is/there are." 

стали -- can be the past tense of стать = to become, begin OR the genitive/dative/prepositional of the noun сталь = steel

Words that are similar, but have different stress

за́мок - (noun) castle

замо́к - (noun) lock

мука́ - (noun) flour

му́ка - (noun) torment
"""


viewAltText : String -> Dict String String -> String
viewAltText id texts =
    case Dict.get id texts of
        Just text ->
            text

        Nothing ->
            ""


altTexts : Dict String String
altTexts =
    Dict.fromList
        [ ]



-- SHARED


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- given an activity question and answer
                    -- update the model's corresponding activity question answer to indicate it's been selected

                -- filter the list of activities to find the activity with a matching label to the one passed to update
                
                -- use `questions` to get the list of questions given an activity,
                    -- filter on these to find the question matching the question passed to update

                -- use `answers` to get the list of answers given a question
                    -- filter on these to find the answer matching the answer passed to update



                -- func is some function which updates the answer's checked field
                -- | activities = map func ( List.filter (\v -> v == a) model.activities)-- update one activity.question.answer that has been clicked
                    -- filter the questions after activities
                        -- filter answers after questions
                            -- mark whatever answer as "checked"
                    -- somewhere needs if "correct" and "checked" -> green feedback
                    -- else -> red feedback