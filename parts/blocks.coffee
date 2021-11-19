if Meteor.isClient
    Template.comments.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.comments.onCreated ->
        if Router.current().params.doc_id
            parent = Docs.findOne Router.current().params.doc_id
        else
            parent = Docs.findOne Template.parentData()._id
        if parent
            @autorun => Meteor.subscribe 'children', 'comment', parent._id
    Template.comments.helpers
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            Docs.find
                parent_id:parent._id
                model:'comment'
    Template.print_this.events
        'click .print_this': -> console.log @
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id







    Template.follow.helpers
        followers: ->
            Meteor.users.find
                _id: $in: @follower_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.follow.events
        'click .follow': ->
            Docs.update @_id,
                $addToSet:follower_ids:Meteor.userId()
        'click .unfollow': ->
            Docs.update @_id,
                $pull:follower_ids:Meteor.userId()
   
   
    Template.send_points_button.helpers
        is_current_user: -> Session.get('current_username') is Router.current().params.username
        # is_friend: ->
        #     user = Docs.findOne username:Router.current().params.username
        #     # Meteor.userId() in user.friend_ids
        #     user._id in Session.get('current_user').friend_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.send_points_button.events
        'click .send_points': ->
            console.log @
            user = Docs.findOne username:Router.current().params.username
            Meteor.users.update Meteor.userId(),
                $addToSet:friend_ids:user._id
                
            $('body').toast({
                title: "#{Router.current().params.username} added to friend list"
                # message: 'Please see desk staff for key.'
                class : 'success'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                
        'click .remove_friend': ->
            user = Docs.findOne username:Router.current().params.username
            Meteor.users.update Meteor.userId(),
                $pull:friend_ids:user._id
            $('body').toast({
                title: "#{Router.current().params.username} removed from friend list"
                # message: 'Please see desk staff for key.'
                class : 'info'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                
                
                
                
                
    Template.friend_button.helpers
        is_current_user: -> Session.get('current_username') is Router.current().params.username
        is_friend: ->
            user = Docs.findOne username:Router.current().params.username
            # Meteor.userId() in user.friend_ids
            user._id in Session.get('current_user').friend_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.friend_button.events
        'click .add_friend': ->
            user = Docs.findOne username:Router.current().params.username
            Meteor.users.update Meteor.userId(),
                $addToSet:friend_ids:user._id
                
            $('body').toast({
                title: "#{Router.current().params.username} added to friend list"
                # message: 'Please see desk staff for key.'
                class : 'success'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                
        'click .remove_friend': ->
            user = Docs.findOne username:Router.current().params.username
            Meteor.users.update Meteor.userId(),
                $pull:friend_ids:user._id
            $('body').toast({
                title: "#{Router.current().params.username} removed from friend list"
                # message: 'Please see desk staff for key.'
                class : 'info'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })

    Template.voting.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->


    Template.voting_small.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->


    Template.bookmark_button.events
        'click .bookmark': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Docs.update @_id, 
                $addToSet: 
                    bookmarker_ids: Meteor.userId()
            Meteor.users.update Meteor.userId(), 
                $addToSet:
                    bookmark_ids:@_id
            $('body').toast({
                title: "bookmarked"
                # message: 'Please see desk staff for key.'
                class : 'success'
                position:'bottom right'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })



        'click .unbookmark': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Docs.update @_id, 
                $pull:
                    bookmarker_ids: Meteor.userId()
            Meteor.users.update Meteor.userId(), 
                $pull:
                    bookmark_ids:@_id
            $('body').toast({
                title: "unbookmarked"
                # message: 'Please see desk staff for key.'
                class : 'info'
                position:'bottom right'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                    
                    
    Template.bookmark_button.helpers
        bookmarked: ->
            @bookmarker_ids and Meteor.userId() in @bookmarker_ids

    # Template.doc_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
    # Template.doc_card.helpers
    #     doc: ->
    #         Docs.findOne
    #             _id:Template.currentData().doc_id





    # Template.call_watson.events
    #     'click .autotag': ->
    #         doc = Docs.findOne Router.current().params.doc_id
    #         console.log doc
    #         console.log @
    #
    #         Meteor.call 'call_watson', doc._id, @key, @mode

    Template.voting_full.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @




    Template.role_editor.onCreated ->
        @autorun => Meteor.subscribe 'model', 'role'



    Template.user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.user_card.helpers
        user: -> Docs.findOne @valueOf()


    # Template.set_limit.events
    #     'click .set_limit': ->
    #         Session.set('limit',parseInt(@amount))



    Template.big_user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.big_user_card.helpers
        user: -> Docs.findOne username:@valueOf()



    Template.set_sort_direction.events
        'click .set_sort_direction': ->
            if Session.get('sort_direction') is -1
                Session.set('sort_direction', 1)
            else
                Session.set('sort_direction', -1)




    Template.username_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.username_info.events
        'click .goto_profile': ->
            user = Docs.findOne username:@valueOf()
            if user.is_current_member
                Router.go "/member/#{user.username}/"
            else
                Router.go "/user/#{user.username}/"
    Template.username_info.helpers
        user: -> Docs.findOne username:@valueOf()




    Template.user_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info.helpers
        user_doc: -> Docs.findOne @valueOf()


    Template.toggle_edit.events
        'click .toggle_edit': ->
            console.log @
            console.log Template.currentData()
            console.log Template.parentData()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)




    Template.user_list_info.onCreated ->
        @autorun => Meteor.subscribe 'user', @data

    Template.user_list_info.helpers
        user: ->
            console.log @
            Docs.findOne @valueOf()



    Template.user_field.helpers
        key_value: ->
            user = Docs.findOne Router.current().params.doc_id
            user["#{@key}"]

    Template.user_field.events
        'blur .user_field': (e,t)->
            value = t.$('.user_field').val()
            Meteor.users.update Router.current().params.doc_id,
                $set:"#{@key}":value


    Template.goto_model.events
        'click .goto_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false



    Template.user_list_toggle.onCreated ->
        @autorun => Meteor.subscribe 'user_list', Template.parentData(),@key
    Template.user_list_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"]
                Docs.update parent._id,
                    $pull:"#{@key}":Meteor.userId()
            else
                Docs.update parent._id,
                    $addToSet:"#{@key}":Meteor.userId()
    Template.user_list_toggle.helpers
        user_list_toggle_class: ->
            if Session.get('current_user')
                parent = Template.parentData()
                if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then '' else 'basic'
            else
                'disabled'
        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
        list_users: ->
            parent = Template.parentData()
            Meteor.users.find _id:$in:parent["#{@key}"]


    Template.doc_array_togggle.helpers
        user_list_toggle_class: ->
            if Session.get('current_user')
                parent = Template.parentData()
                if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then '' else 'basic'
            else
                'disabled'
        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
        list_users: ->
            parent = Template.parentData()
            Meteor.users.find _id:$in:parent["#{@key}"]




    Template.viewing.events
        'click .mark_read': (e,t)->
            unless @read_ids and Meteor.userId() in @read_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> 
            if @read_ids 
                Meteor.userId() in @read_ids
        readers: ->
            readers = []
            if @read_ids
                for reader_id in @read_ids
                    unless reader_id is @author_id
                        readers.push Docs.findOne reader_id
            readers



    Template.email_validation_check.events
        'click .send_verification': ->
            console.log @
            if confirm 'send verification email?'
                Meteor.call 'verify_email', @_id, ->
                    alert 'verification email sent'
        'click .toggle_email_verified': ->
            console.log @emails[0].verified
            if @emails[0]
                Meteor.users.update @_id,
                    $set:"emails.0.verified":true


    Template.add_button.onCreated ->
        # console.log @
        Meteor.subscribe 'model_from_slug', @data.model
    Template.add_button.helpers
        model: ->
            data = Template.currentData()
            Docs.findOne
                model: 'model'
                slug: data.model
    Template.add_button.events
        'click .add': ->
            new_id = Docs.insert
                model: @model
            Router.go "/m/#{@model}/#{new_id}/edit"

    Template.set_sort_key.helpers
        sort_key_class: -> if Session.equals('sort_key',@key) then 'blue' else ''
    Template.set_sort_key.events
        'click .set_key': (e,t)->
            console.log @
            Session.set('sort_key', @key)
            Session.set('sort_label', @label)
            Session.set('sort_icon', @icon)


    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000


    Template.add_model_button.events
        'click .add': ->
            new_id = Docs.insert model: @model
            Router.go "/edit/#{new_id}"

    Template.view_user_button.events
        'click .view_user': ->
            Router.go "/user/#{username}"


    Template.session_edit_value_button.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            Session.set(@key, @value)

    Template.session_edit_value_button.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.equals(@key,@value)
                res += ' active'
            else 
                res += ' basic'
            # console.log res
            res



    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.get(@key)
                res += ' blue'
            else
                res += ' '

            # console.log res
            res

if Meteor.isServer
    Meteor.methods
        'send_kiosk_message': (message)->
            parent = Docs.findOne message.parent._id
            Docs.update message._id,
                $set:
                    sent: true
                    sent_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'kiosk_message_sent'
                text:"kiosk message sent"


    Meteor.publish 'children', (model, parent_id, limit)->
        # console.log model
        # console.log parent_id
        limit = if limit then limit else 10
        Docs.find {
            model:model
            parent_id:parent_id
        }, limit:limit
        
        
if Meteor.isClient
    Template.doc_array_togggle.helpers
        doc_array_toggle_class: ->
            parent = Template.parentData()
            # user = Docs.findOne Router.current().params.username
            if parent["#{@key}"] and @value in parent["#{@key}"] then 'active' else 'basic'
    Template.doc_array_togggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            console.log 'key', @key, @value
            console.log 'parent', parent
            if parent["#{@key}"]
                if @value in parent["#{@key}"]
                    Docs.update parent._id,
                        $pull: "#{@key}":@value
                else
                    Docs.update parent._id,
                        $addToSet: "#{@key}":@value
            else
                Docs.update parent._id,
                    $addToSet: "#{@key}":@value




Meteor.methods
    mark_read: (doc_id)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $addToSet:
                read_ids: Meteor.userId()
            $set:
                last_viewed: Date.now() 
            $inc:views:1
    mark_unread: (doc_id)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $pull:
                read_ids: Meteor.userId()
            $inc:views:-1





if Meteor.isClient
    Template.session_key_value_edit.events
        'click .set_key_value': ->
            console.log 'hi'
            # parent = Template.parentData()
            # Docs.update parent._id,
            #     $set: "#{@key}": @value
            if Session.equals('sort_direction',-1)
                Session.set('sort_direction',1)
            else 
                Session.set('sort_direction',-1)
            Session.set("#{@key}",@value)
            
            
    Template.session_key_value_edit.helpers
        set_key_value_class: ->
            parent = Template.parentData()
            # console.log parent
            # if parent["#{@key}"] is @value then 'active' else ''
            if Session.equals("#{@key}",@value) then 'active large' else 'basic'
    
    
    
            
    Template.key_value_edit.helpers
        set_key_value_class: ->
            parent = Template.parentData()
            # console.log parent
            # if parent["#{@key}"] is @value then 'active' else ''
            if parent["#{@key}"] is @value then 'active large' else 'basic'
    
    
    Template.key_value_edit.events
        'click .set_key_value': ->
            # console.log 'hi'
            parent = Template.parentData()
            # console.log parent, @key, @value
            if Docs.findOne parent._id
                Docs.update parent._id,
                    $set: "#{@key}": @value
            else 
                Meteor.users.update parent._id,
                    $set: "#{@key}": @value

