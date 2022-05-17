if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
    Template.post_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.post_view.onCreated ->
        @autorun => @subscribe 'post_tips',Router.current().params.doc_id, ->
    Template.post_view.events 
        'click .tip_post_10': ->
            # console.log 'hi'
            new_id = 
                Docs.insert 
                    model:'transfer'
                    post_id:Router.current().params.doc_id
                    complete:true
                    amount:10
                    transfer_type:'tip'
                    tags:['tip']
            Meteor.call 'calc_user_points', ->
            $('body').toast(
                showIcon: 'coins'
                message: "post tipped"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
                
        'click .tip_post_50': ->
            # console.log 'hi'
            new_id = 
                Docs.insert 
                    model:'transfer'
                    post_id:Router.current().params.doc_id
                    complete:true
                    amount:50
                    transfer_type:'tip'
                    tags:['tip']
            Meteor.call 'calc_user_points', ->
    Template.post_view.helpers 
        post_tip_docs: ->
            Docs.find 
                model:'transfer'
                
                
if Meteor.isServer 
    Meteor.publish 'post_tips', (post_id)->
        Docs.find 
            model:'transfer'
            post_id:post_id
                
if Meteor.isClient
    # Template.posts.helpers
    #     post_docs: ->
    #         Docs.find {
    #             model:'post'
    #         }, 
    #             sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
    #             limit:Session.get('limit')        
                
    Template.post_edit.events
        'click .delete_post': ->
            if confirm 'delete post?'
                Docs.remove @_id
                Router.go "/docs"
