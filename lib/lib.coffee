@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Results = new Meteor.Collection 'results'
@Markers = new Meteor.Collection 'markers'


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

# Router.onBeforeAction(force_loggedin, {
#   # only: ['admin']
#   # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
#   except: [
#     'food'
#     'register'
#     'users'
#     'services'
#     'service_view'
#     'products'
#     'product_view'
#     'posts'
#     'post_view'
#     'home'
#     'forgot_password'
#     'reset_password'
#     'user_orders'
#     'user_food'
#     'user_finance'
#     'user_dashboard'
#     'verify-email'
#     'food_view'
#   ]
# });


Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})


# Router.route '/m/:model_slug', (->
#     @render 'delta'
#     ), name:'delta'
# Router.route '/m/:model_slug/:doc_id/edit', -> @render 'model_doc_edit'
# Router.route '/m/:model_slug/:doc_id/', (->
#     @render 'model_doc_view'
#     ), name:'doc_view'
# Router.route '/model/edit/:doc_id', -> @render 'model_edit'

# Router.route '/user/:username', -> @render 'user'
Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'user_layout', 'user_section'
Router.route '/forgot_password', -> @render 'forgot_password'

# Router.route "/food/:food_id", -> @render 'food_doc'

Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/login', -> @render 'login'



Docs.before.insert (userId, doc)->
    # doc._author_id = Meteor.userId()
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    # doc._author_id = Meteor.userId()
    # if Meteor.user()
    #     doc._author_username = Meteor.user().username
    doc.app = 'goldrun'
    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return

if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    # author: -> Docs.findOne @_author_id
    # cook: -> Docs.findOne @cook_user_id

    when: -> moment(@_timestamp).fromNow()
    ten_tags: -> if @tags then @tags[..10]
    five_tags: -> if @tags then @tags[..4]
    three_tags: -> if @tags then @tags[..2]
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    # from_user: ->
    #     if @from_user_id
    #         Docs.findOne @from_user_id
    # to_user: ->
    #     if @to_user_id
    #         Docs.findOne @to_user_id


    food_orders: ->
        # if @order_ids
        Docs.find
            food_id:@_id
            model:'order'
        # else
        #     []
    order_food: ->
        Docs.findOne
            model:'food'
            _id:@food_id
    order_post: ->
        Docs.findOne
            model:'post'
            _id:@post_id

    order_total_transaction_amount: ->
        @serving_purchase_price+@cook_tip


    order: ->
        Docs.findOne
            model:'order'
            _id:@order_id



    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Docs.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Docs.findOne downvoter_id
                downvoters.push downvoter
            downvoters


Meteor.methods
    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        upvotes:1
                        points:1
            Docs.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Docs.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        downvotes:1
            Docs.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Docs.update doc._author_id,
                $inc:anon_karma:-1



if Meteor.isServer
    # Meteor.publish 'doc', (id)->
    #     doc = Docs.findOne id
    #     user = Docs.findOne id
    #     if doc
    #         Docs.find id
    #     else if user
    #         Docs.find id
    Meteor.publish 'docs', (picked_tags, filter)->
        # user = Docs.findOne @userId
        # console.log picked_tags
        # console.log filter
        self = @
        match = {}
        if Meteor.user()
            unless Meteor.user().roles and 'dev' in Meteor.user().roles
                match.view_roles = $in:Meteor.user().roles
        else
            match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        if filter then match.model = filter

        Docs.find match, sort:_timestamp:-1
