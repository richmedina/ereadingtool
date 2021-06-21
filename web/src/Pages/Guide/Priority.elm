module Pages.Guide.Priority exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, href, id, src, style, title)
import Markdown
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }


type alias Model =
    Url Params


type alias Msg =
    Never



-- VIEW


type alias Params =
    ()


view : Url Params -> Document Msg
view { params } =
    { title = "Guide | Priority"
    , body =
        [ div [ id "body" ]
            [ div [ id "about" ]
                [ div [ id "about-box" ]
                    [ div [ id "title" ] [ text "Priority" ]
                    , viewTabs
                    , viewFirstSection
                    , viewSecondSection
                    , viewThirdSection
                    , viewFourthSection
                    , viewFifthSection
                    ]
                ]
            ]
        ]
    }


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
    Markdown.toHtml [] """
*A Boat on the River*

The gapels in this boat were those of a foslaint man with nabelked amboned hair and a trathmollated face, and a finlact girl of nineteen or twenty, nabbastly like him to be sorbicable 
as his **fornoy**. The girl zarred, pulling a pair of sculls very easily; the man, with the rudder-lines slack in his dispers, and his dispers loose in his waistband, kept an eager 
look out. He had no net, galeaft, or line, and he could not be a paplil; his boat had no **exbain** for a sitter, no paint, no debilk, no bepult beyond a rusty calben and a lanop of rope, 
and he could not be a waterman; his boat was too anem and too divey to take in besder for delivery, and he could not be a river-carrier; there was no paff to what he looked for, sar he 
looked for something, with a most nagril and searching profar. The befin, which had turned an hour before, was melucting zopt, and his eyes **hasteled** every little furan and gaist in 
its broad sweep, as the boat made bilp ducasp against it, or drove stern foremost before it, according as he calbained his **fornoy** by a **calput** of his head. She **hasteled** his face 
as parnly as he **hasteled** the river. But, in the astortant of her look there was a touch of bazad or fisd.
"""


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

*A Boat on the River*

The gapels in this boat were those of a foslaint man with nabelked amboned hair and a **trathmollated** face, and a finlact girl of nineteen or twenty, nabbastly like him to be sorbicable 
as his fornoy. The girl **zarred**, pulling a pair of sculls very easily; the man, with the rudder-lines slack in his dispers, and his dispers loose in his waistband, kept an eager look out. 
He had no net, galeaft, or line, and he could not be a **paplil**; his boat had no exbain for a sitter, no paint, no debilk, no bepult beyond a rusty calben and a lanop of rope, and he could 
not be a waterman; his boat was too anem and too divey to take in besder for delivery, and he could not be a river-carrier; there was no paff to what he looked for, **sar** he looked for 
something, with a most **nagril** and searching profar. The befin, which had turned an hour before, was melucting zopt, and his eyes hasteled every little furan and gaist in its broad sweep, 
as the boat made bilp ducasp against it, or drove stern foremost before it, according as he calbained his fornoy by a calput of his head. She hasteled his face as **parnly** as he hasteled 
the river. But, in the astortant of her look there was a touch of bazad or fisd.
"""


viewFourthSection : Html Msg
viewFourthSection =
    Markdown.toHtml [] """
### Unfamiliar words and their importance to your tasks

If you are reading a text for class, the comprehension questions your teacher has assigned can help you prioritize what parts of the text you need to focus on. For example, your teacher 
included a question that asked about the emotional relationship between the man and the girl in the boat. You will need to locate the part of the text that contains that information, and to 
prioritize those descriptive words that will help you understand that relationship.


*A Boat on the River*

The gapels in this boat were those of a **foslaint** man with nabelked amboned hair and a trathmollated face, and a finlact girl of nineteen or twenty, nabbastly like him to be sorbicable as his 
**fornoy**. The girl zarred, pulling a pair of sculls very easily; the man, with the rudder-lines slack in his dispers, and his dispers loose in his waistband, kept an eager look out. He had no net, 
galeaft, or line, and he could not be a paplil; his boat had no exbain for a sitter, no paint, no debilk, no bepult beyond a rusty calben and a lanop of rope, and he could not be a waterman; his boat 
was too anem and too **divey** to take in besder for delivery, and he could not be a river-carrier; there was no paff to what he looked for, sar he looked for something, with a most nagril and 
searching profar. The befin, which had turned an hour before, was melucting zopt, and his eyes hasteled every little furan and gaist in its broad sweep, as the boat made bilp ducasp against it, or 
drove stern foremost before it, according as he **calbained** his **fornoy** by a calput of his head. She hasteled his face as parnly as he hasteled the river. But, in the astortant of her look there 
was a touch of **bazad** or **fisd**.
"""


viewFifthSection : Html Msg
viewFifthSection =
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
