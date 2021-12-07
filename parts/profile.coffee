if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'



    Template.profile.onCreated ->
        Meteor.call 'calc_user_points', Router.current().params.username, ->


        
if Meteor.isClient
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_deposits', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_rentals', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_orders', Router.current().params.username, ->

    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile.events
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username, ->

        'click .create_profile': ->
            Docs.insert 
                model:'user'
                username:Router.current().params.username
    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.profile.helpers
        user_rental_docs: ->
            Docs.find
                model:'rental'
                _author_username:Router.current().params.username
        reserved_from_docs: ->
            Docs.find
                model:'order'
                _author_username:Router.current().params.username
        user_order_docs: ->
            Docs.find
                model:'order'
                _author_username:Router.current().params.username

    Template.logout_other_clients_button.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

    Template.logout_button.events
        'click .logout': (e,t)->
            Meteor.call 'insert_log', 'logout', Session.get('current_userid'), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('slide left', 500)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
                # message: 'Please see desk staff for key.'
                class : 'success'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
            
if Meteor.isServer
    Meteor.publish 'user_deposits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'deposit'
            _author_username:username
    Meteor.methods
        calc_user_points: (username)->
            user = Docs.findOne username:username
            point_total = 10
            if user
                deposits = 
                    Docs.find 
                        model:'deposit'
                        _author_id:user._id
                for deposit in deposits.fetch()
                    if deposit.amount
                        point_total += deposit.amount
                orders = 
                    Docs.find
                        model:'order'
                        _author_id:user._id
                for order in orders.fetch()
                    if order.total_amount
                        point_total += order.total_amount
                console.log 'calc user points', username, point_total
                Docs.update user._id,   
                    $set:points:point_total
    
            
if Meteor.isClient
    Template.profile.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'order'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Docs.findOne username:Router.current().params.username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Docs.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    Template.profile.events
        'click .add_points': ->
            amount = parseInt $('.deposit_amount').val()
            # amount_times_100 = parseInt amount*100
            # calculated_amount = amount_times_100*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount
            Docs.insert
                model:'deposit'
                amount: amount
            Meteor.users.update Meteor.userId(),
                $inc: points: amount


    #     'click .initial_withdrawal': ->
    #         withdrawal_amount = parseInt $('.withdrawal_amount').val()
    #         if confirm "initiate withdrawal for #{withdrawal_amount}?"
    #             Docs.insert
    #                 model:'withdrawal'
    #                 amount: withdrawal_amount
    #                 status: 'started'
    #                 complete: false
    #             Docs.update Session.get('current_userid'),
    #                 $inc: credit: -withdrawal_amount

    #     'click .cancel_withdrawal': ->
    #         if confirm "cancel withdrawal for #{@amount}?"
    #             Docs.remove @_id
    #             Docs.update Session.get('current_userid'),
    #                 $inc: credit: @amount



    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'order'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        deposit_docs: ->
            Docs.find {
                model:'deposit'
                # _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_orders: ->
            Docs.find {
                model:'order'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_orders: ->
            Docs.find {
                model:'order'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1





    Template.profile.onCreated ->
        @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'rental'
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'user_deposts', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'model_docs', 'order', ->
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'


    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'order'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_orders: ->
            Docs.find {
                model:'order'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_orders: ->
            Docs.find {
                model:'order'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1


        current_orders: ->
            Docs.find
                model:'order'
                user_username:Router.current().params.username
        upcoming_orders: ->
            Docs.find
                model:'order'
                user_username:Router.current().params.username


            