if Meteor.isClient
    Router.route '/doc/:doc_id/edit', (->
        @layout 'layout'
        @render 'doc_edit'
        ), name:'doc_edit'
    Template.doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
    Template.doc_edit.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000

    Template.doc_edit.events
        'click .publish': ->
            Docs.update @_id, 
                $set:
                    published:true
                    publish_timestamp:Date.now()
    Template.doc_edit.helpers
        model_template: -> "#{@model}_edit"
        doc_data: -> 
            # console.log 'hi'
            Docs.findOne Router.current().params.doc_id
    
    Router.route '/doc/:doc_id/', (->
        @layout 'layout'
        @render 'doc_view'
        ), name:'doc_view'
        
        
    Template.doc_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $().popup(
                inline: true
            )
        , 2000
            
    Template.doc_view.onCreated ->
        @autorun => Meteor.subscribe 'current_viewers', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_by_id', Router.current().params.doc_id, ->
    Template.doc_view.helpers
        model_template: -> "#{@model}_view"
        # current_doc: -> Docs.findOne Router.current().params.doc_id
        doc_data: -> 
            # console.log 'hi'
            Docs.findOne Router.current().params.doc_id
    Template.doc_view.events 
        'click .pick_flat_tag':(e)->
            doc = Docs.findOne Router.current().params.doc_id
            picked_tags.clear()
            picked_tags.push @valueOf()
            $(e.currentTarget).closest('.grid').transition('fly right', 500)
            
            Router.go "/m/#{doc.model}"
            Session.set('model',doc.model)
        
    # Template.doc_card.helpers
    #     card_template: -> "#{@model}_card"
    Template.doc_card.helpers
        item_template: -> "#{@model}_item"
        
    Template.docs.onRendered ->
        Session.set('model',Router.current().params.model)
    Template.docs.onCreated ->
        Session.set('model',Router.current().params.model)
        Session.setDefault('limit',42)
        Session.setDefault('sort_key','_timestamp')
        Session.setDefault('sort_icon','clock')
        Session.setDefault('sort_label','added')
        Session.setDefault('sort_direction',-1)
        # @autorun => @subscribe 'model_docs', 'post', ->
        @autorun => @subscribe 'user_info_min', ->
        @autorun => @subscribe 'facet_sub',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
            picked_timestamp_tags.array()
    
        @autorun => @subscribe 'doc_results',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    
    
    Template.sort_key_toggle.helpers
        sort_title:-> 'click to toggle sort'
        sort_icon:-> Session.get('sort_icon')
    Template.sort_key_toggle.events
        'click .toggle_sort': ->
            console.log 'hi'
            if Session.equals('sort_key','views')
                Session.set('sort_key','_timestamp')
                Session.set('sort_label','added')
                Session.set('sort_icon','clock')
            else if Session.equals('sort_key','_timestamp')
                Session.set('sort_key','points')
                Session.set('sort_label','points')
                Session.set('sort_icon','hashtag')
            else if Session.equals('sort_key','points')
                Session.set('sort_key','views')
                Session.set('sort_label','views')
                Session.set('sort_icon','eye')
            $('body').toast({
                title: "sorting by #{Session.get('sort_label')}"
                class : 'info'
                position:'bottom center'
                })

    
    Template.docs.helpers
        current_model: -> Session.get('model')
        result_docs: ->
            Docs.find {
                model:Session.get('model')
            }, 
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')        
                
if Meteor.isServer
    Meteor.publish 'group_from_doc_id', (doc_id)->
        doc = Docs.findOne doc_id 
        if doc and doc.group_id
            Docs.find 
                model:'group'
                _id:doc.group_id