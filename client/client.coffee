@selected_rental_tags = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0
    #   'click .refresh_gps': ->
    #         navigator.geolocation.getCurrentPosition (position) =>
    #             console.log 'navigator position', position
    #             Session.set('current_lat', position.coords.latitude)
    #             Session.set('current_long', position.coords.longitude)
                
    #             console.log 'saving long', position.coords.longitude
    #             console.log 'saving lat', position.coords.latitude
            
    #             pos = Geolocation.currentLocation()
    #             Docs.update Router.current().params.doc_id, 
    #                 $set:
    #                     lat:position.coords.latitude
    #                     long:position.coords.longitude
 

Template.home.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'public_posts', ->
    # @autorun -> Meteor.subscribe 'model_docs', 'post', ->
    @autorun -> Meteor.subscribe 'model_docs', 'chat_message', ->
    @autorun -> Meteor.subscribe 'model_docs', 'stat', ->
    @autorun -> Meteor.subscribe 'all_users', ->
        
Template.home.onRendered ->
    Meteor.call 'log_homepage_view', ->        
Template.home.events 
    'keyup .add_public_chat': (e,t)->
        val = t.$('.add_public_chat').val()
        if e.which is 13
            if val.length > 0
                new_id = 
                    Docs.insert 
                        model:'chat_message'
                        chat_type:'public'
                        body:val
                val = t.$('.add_public_chat').val('')
                $('body').toast({
                    title: "message sent"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    position:'bottom center'
                    # className:
                    #     toast: 'ui massive message'
                    # displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
                    
    'click .remove_comment': ->
        if confirm 'remove comment? cant be undone'
            Docs.remove @_id
    
    
Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_leftbar')
    , 3000
    Meteor.setTimeout ->
        $('.ui.rightbar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 3000
    Meteor.setTimeout ->
        $('.ui.topbar.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_topbar')
    , 2000
    
Template.nav.events
    'click .toggle_rightbar': ->
        $('.ui.rightbar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')



Template.rightbar.events
    'click .logout': ->
        Session.set('logging_out', true)
        Meteor.logout ->
            Session.set('logging_out', false)
            
            
    
Template.rightbar.helpers
    

    
        
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'users'
    # @autorun -> Meteor.subscribe 'users_by_role','staff'
    # @autorun -> Meteor.subscribe 'unread_messages'

Template.nav.events
    'keyup .global_search': (e,t)->
        query = $('.global_search').val()
        Session.set('global_query',query)

$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.nav.events
    'click .add_rental': ->
        new_id = 
            Docs.insert 
                model:'rental'
        Router.go "/rental/#{new_id}/edit"
    # 'click .locate': ->
    #     navigator.geolocation.getCurrentPosition (position) =>
    #         console.log 'navigator position', position
    #         Session.set('current_lat', position.coords.latitude)
    #         Session.set('current_long', position.coords.longitude)

Template.layout.events
    'click .fly_down': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('swing down', 500)
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('swing up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('swing left', 500)
    'click .fly_right': (e,t)->
        console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('swing right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('swing right', 500)
        
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'
