@picked_tags = new ReactiveArray []

Template.registerHelper 'unescaped', () ->
    txt = document.createElement("textarea")
    txt.innerHTML = @rd.selftext_html
    return txt.value

        # html.unescape(@rd.selftext_html)
Template.registerHelper 'unescaped_content', () ->
    txt = document.createElement("textarea")
    txt.innerHTML = @rd.media_embed.content
    return txt.value
    
Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')


Template.registerHelper 'sval', (input)-> Session.get(input)
Template.registerHelper 'is_loading', -> Session.get 'is_loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'is_image', () ->
    # regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
    # match = @url.match(regExp)
    # # console.log 'image match', match
    # if match then true
    # true
    regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
    match = @url.match(regExp)
    # console.log 'image match', match
    if match then true
    # true



Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

# Template.reddit_card.onRendered ->
#     console.log @
#     found_doc = @data
#     if found_doc 
#         unless found_doc.doc_sentiment_label
#             Meteor.call 'call_watson',found_doc._id,'title','html',->
#                 console.log 'autoran watson'

    # @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
Template.reddit.onCreated ->
    Session.setDefault('current_query', null)
    Session.setDefault('dummy', false)
    Session.setDefault('is_loading', false)
    Session.setDefault('sort_key', '_timestamp')
    Session.setDefault('sort_direction', -1)
    # @autorun => @subscribe 'agg_emotions',
    #     picked_tags.array()
    #     Session.get('dummy')
    @autorun => @subscribe 'reddit_tag_results',
        picked_tags.array()
        Session.get('domain')
        Session.get('subreddit')
        Session.get('view_nsfw')
        Session.get('dummy')
    @autorun => @subscribe 'reddit_doc_results',
        picked_tags.array()
        Session.get('domain')
        Session.get('subreddit')
        Session.get('view_nsfw')
        Session.get('sort_key')
        Session.get('sort_direction')
        # Session.get('dummy')



Template.agg_tag.onCreated ->
    # console.log @
    @autorun => @subscribe 'tag_image', @data.name, picked_tags.array(),->
        
Template.agg_tag.helpers
    term_image: ->
        # console.log Template.currentData().name
        found = Docs.findOne {
            tags:$in:[Template.currentData().name]
            "watson.metadata.image":$exists:true
        }, sort:ups:-1
        # console.log 'found image', found
        found
Template.agg_tag.events
    'click .result': (e,t)->
        # Meteor.call 'log_term', @title, ->
        picked_tags.push @name
        $('#search').val('')
        Session.set('current_query', null)
        Session.set('searching', true)
        Session.set('is_loading', true)
        # Meteor.call 'call_wiki', @name, ->

        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('is_loading', false)
            Session.set('searching', false)
        # Meteor.setTimeout ->
        #     Session.set('dummy',!Session.get('dummy'))
        # , 5000
        

Template.reddit.events
    'click .select_query': ->
        picked_tags.push @name
        Meteor.call 'search_reddit', picked_tags.array(), ->
        $('#search').val('')
        Session.set('current_query', null)

Template.reddit_card.helpers
    five_cleaned_tags: ->
        # console.log picked_tags.array()
        # console.log @tags[..5] not in picked_tags.array()
        # console.log _.without(@tags[..5],picked_tags.array())
        if picked_tags.array().length
            _.difference(@tags[..10],picked_tags.array())
        #     @tags[..5] not in picked_tags.array()
        else 
            @tags[..5]
Template.reddit_card.events
    'click .pick_flat_tag': -> 
        picked_tags.push @valueOf()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
    # 'click .pick_subreddit': -> Session.set('subreddit',@subreddit)
    # 'click .pick_domain': -> Session.set('domain',@domain)
    'click .autotag': (e)->
        console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # if @rd and @rd.selftext_html
        #     dom = document.createElement('textarea')
        #     # dom.innerHTML = doc.body
        #     dom.innerHTML = @rd.selftext_html
        #     # console.log 'innner html', dom.value
        #     # return dom.value
        #     Docs.update @_id,
        #         $set:
        #             parsed_selftext_html:dom.value
        
        # doc = Template.parentData()
        # doc = Docs.findOne Template.parentData()._id
        # Meteor.call 'call_watson', Template.parentData()._id, parent.key, @mode, ->
        # if doc 
        # console.log 'calling client watson',doc, 'rd.selftext'
        Meteor.call 'call_watson', @_id, 'rd.selftext', 'html', ->
            # $(e.currentTarget).closest('.button').transition('scale', 500)
            # $('body').toast({
            #     title: "emotions brokedown"
            #     # message: 'Please see desk staff for key.'
            #     class : 'success'
            #     showIcon:'chess'
            #     # showProgress:'bottom'
            #     position:'bottom right'
            #     # className:
            #     #     toast: 'ui massive message'
            #     # displayTime: 5000
            #     transition:
            #       showMethod   : 'zoom',
            #       showDuration : 250,
            #       hideMethod   : 'fade',
            #       hideDuration : 250
            #     })
            # Session.set('dummy', !Session.get('dummy'))
        # Meteor.call 'call_watson', doc._id, @key, @mode, ->
    
Template.reddit.events
    'click .print_me': ->
        console.log @
    'click .unpick_tag': ->
        picked_tags.remove @valueOf()
        console.log picked_tags.array()
        if picked_tags.array().length > 0
            Session.set('is_loading', true)
            Meteor.call 'search_reddit', picked_tags.array(), =>
                Session.set('is_loading', false)
            # Meteor.setTimeout ->
            #     Session.set('dummy', !Session.get('dummy'))
            # , 5000

    # # 'keyup #search': _.throttle((e,t)->
    'click #search': (e,t)->
        Session.set('dummy', !Session.get('dummy'))
    'keydown #search': (e,t)->
        query = $('#search').val()
        # if query.length > 0
        Session.set('current_query', query)
        # console.log Session.get('current_query')
        if query.length > 0
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    # Session.set('searching', true)
                    picked_tags.push search
                    # console.log 'search', search
                    Session.set('is_loading', true)
                    Meteor.call 'search_reddit', picked_tags.array(), ->
                        Session.set('is_loading', false)
                        # Session.set('searching', false)
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 5000
                    $('#search').val('')
                    Session.set('current_query', null)
    # , 200)

    # 'keydown #search': _.throttle((e,t)->
    #     if e.which is 8
    #         search = $('#search').val()
    #         if search.length is 0
    #             last_val = picked_tags.array().slice(-1)
    #             console.log last_val
    #             $('#search').val(last_val)
    #             picked_tags.pop()
    #             Meteor.call 'search_reddit', picked_tags.array(), ->
    # , 1000)

    'click .reconnect': -> Meteor.reconnect()

    'click .toggle_tag': (e,t)-> picked_tags.push @valueOf()
    # 'click .pick_subreddit': -> Session.set('subreddit',@name)
    # 'click .unpick_subreddit': -> Session.set('subreddit',null)
    # 'click .pick_domain': -> Session.set('domain',@name)
    # 'click .unpick_domain': -> Session.set('domain',null)
    'click .print_me': (e,t)->
        console.log @
        
Template.reddit_card.helpers
    unescaped: -> 
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.selftext_html
        return txt.value

        # html.unescape(@rd.selftext_html)
    unescaped_content: -> 
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.media_embed.content
        return txt.value

        # html.unescape(@rd.selftext_html)

    
Template.reddit.helpers
    current_bg:->
        console.log picked_tags.array()
        found = Docs.findOne {
            model:'reddit'
            tags:$in:picked_tags.array()
            "watson.metadata.image":$exists:true
            # thumbnail:$nin:['default','self']
        },sort:ups:-1
        if found
            console.log 'found bg'
            found.watson.metadata.image
        else 
            console.log 'no found bg'

    emotion_avg_result: ->
        Results.findOne 
            model:'emotion_avg'
    # in_dev: -> Meteor.isDevelopment()
    not_searching: ->
        picked_tags.array().length is 0 and Session.equals('current_query',null)
        
    search_class: ->
        if Session.get('current_query')
            'massive active' 
        else
            if picked_tags.array().length is 0
                'big'
            else 
                'big' 
          
    # domain_results: ->
    #     Results.find 
    #         model:'domain'
    # picked_subreddit: -> Session.get('subreddit')
    # picked_domain: -> Session.get('domain')
    # subreddit_results: ->
    #     Results.find 
    #         model:'subreddit'
                
    curent_date_setting: -> Session.get('date_setting')

    term_icon: ->
        console.log @
    doc_results: ->
        current_docs = Docs.find()
        # if Session.get('selected_doc_id') in current_docs.fetch()
        # console.log current_docs.fetch()
        # Docs.findOne Session.get('selected_doc_id')
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find({model:'reddit'}, 
            limit:20
            sort:
                ups:-1
                # "#{Session.get('sort_key')}":Session.get('sort_direction')
        )

    is_loading: -> Session.get('is_loading')

    tag_result_class: ->
        # ec = omega.emotion_color
        # console.log @
        # console.log omega.total_doc_result_count
        total_doc_result_count = Docs.find({}).count()
        console.log total_doc_result_count
        percent = @count/total_doc_result_count
        # console.log 'percent', percent
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        whole = parseInt(percent*10)+1
        # console.log 'whole', whole

        # if whole is 0 then "#{ec} f5"
        if whole is 0 then "f5"
        else if whole is 1 then "f11"
        else if whole is 2 then "f12"
        else if whole is 3 then "f13"
        else if whole is 4 then "f14"
        else if whole is 5 then "f15"
        else if whole is 6 then "f16"
        else if whole is 7 then "f17"
        else if whole is 8 then "f18"
        else if whole is 9 then "f19"
        else if whole is 10 then "f20"


    connection: ->
        # console.log Meteor.status()
        Meteor.status()
    connected: -> Meteor.status().connected

    unpicked_tags: ->
        # # doc_count = Docs.find().count()
        # # console.log 'doc count', doc_count
        # # if doc_count < 3
        # #     Tags.find({count: $lt: doc_count})
        # # else
        # unless Session.get('searching')
        #     unless Session.get('current_query').length > 0
        Results.find({model:'tag'})

    result_class: ->
        if Template.instance().subscriptionsReady()
            ''
        else
            'disabled'

    picked_tags: -> picked_tags.array()

    picked_tags_plural: -> picked_tags.array().length > 1

    searching: ->
        # console.log 'searching?', Session.get('searching')
        Session.get('searching')

    one_post: -> Docs.find().count() is 1

    two_posts: -> Docs.find().count() is 2
    three_posts: -> Docs.find().count() is 3
    four_posts: -> Docs.find().count() is 4
    more_than_four: -> Docs.find().count() > 4
    one_result: ->
        Docs.find().count() is 1

    docs: ->
        # if picked_tags.array().length > 0
        cursor =
            Docs.find {
                model:'reddit'
            },
                sort:
                    "#{Session.get('sort_key')}":Session.get('sort_direction')
        # console.log cursor.fetch()
        cursor


    home_subs_ready: ->
        Template.instance().subscriptionsReady()
        
    #     @autorun => Meteor.subscribe 'current_doc', Router.current().params.doc_id
    #     console.log @
    # Template.array_view.events
    #     'click .toggle_post_filter': ->
    #         console.log @
    #         value = @valueOf()
    #         console.log Template.currentData()
    #         current = Template.currentData()
    #         console.log Template.parentData()
            # match = Session.get('match')
            # key_array = match["#{current.key}"]
            # if key_array
            #     if value in key_array
            #         key_array = _.without(key_array, value)
            #         match["#{current.key}"] = key_array
            #         picked_tags.remove value
            #         Session.set('match', match)
            #     else
            #         key_array.push value
            #         picked_tags.push value
            #         Session.set('match', match)
            #         Meteor.call 'search_reddit', picked_tags.array(), ->
            #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
            #         console.log @
            #         # match["#{current.key}"] = ["#{value}"]
            # else
            # if value in picked_tags.array()
            #     picked_tags.remove value
            # else
            #     # match["#{current.key}"] = ["#{value}"]
            #     picked_tags.push value
            #     # console.log picked_tags.array()
            # # Session.set('match', match)
            # # console.log picked_tags.array()
            # if picked_tags.array().length > 0
            #     Meteor.call 'search_reddit', picked_tags.array(), ->
            # console.log Session.get('match')

    # Template.array_view.helpers
    #     values: ->
    #         # console.log @key
    #         Template.parentData()["#{@key}"]
    #
    #     post_label_class: ->
    #         match = Session.get('match')
    #         key = Template.parentData().key
    #         doc = Template.parentData(2)
    #         # console.log key
    #         # console.log doc
    #         # console.log @
    #         if @valueOf() in picked_tags.array()
    #             'active'
    #         else
    #             'basic'
    #         # if match["#{key}"]
    #         #     if @valueOf() in match["#{key}"]
    #         #         'active'
    #         #     else
    #         #         'basic'
    #         # else
    #         #     'basic'
    #
    