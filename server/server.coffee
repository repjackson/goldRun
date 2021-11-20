Docs.allow
    insert: (userId, doc) -> 
        true    
            # doc._author_id is userId
    update: (userId, doc) ->
        doc
        # if doc.model in ['calculator_doc','simulated_post_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.publish 'count', ->
  Counts.publish this, 'product_counter', Docs.find({model:'product'})
  return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.


Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret




# if Meteor.isProduction
#     SyncedCron.start()
Meteor.publish 'model_from_child_id', (child_id)->
    child = Docs.findOne child_id
    Docs.find
        model:'model'
        slug:child.type


Meteor.publish 'model_fields_from_child_id', (child_id)->
    child = Docs.findOne child_id
    model = Docs.findOne
        model:'model'
        slug:child.type
    Docs.find
        model:'field'
        parent_id:model._id

Meteor.publish 'model_docs', (
    model
    limit=10
    )->
    Docs.find {
        model: model
        app:'goldrun'
    }, limit:limit

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id

Meteor.publish 'me', (id)->
    Meteor.users.find Meteor.userId()


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array

Meteor.publish 'latest_posts', (tags)->
    Docs.find({
        model:'post'
    },{
        sort:_timestamp:-1
        limit:10
    })    

Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug



Meteor.publish 'user_from_username', (username)->
    Meteor.users.find 
        username:username

Meteor.publish 'user_from_id', (user_id)->
    Docs.find user_id

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Docs.find user_id

Meteor.publish 'page', (slug)->
    Docs.find
        model:'page'
        slug:slug


Meteor.publish 'results', (
    query=''
    picked_tags=[]
    picked_location_tags=[]
    limit=42
    sort_key='_timestamp'
    sort_direction=-1
    view_delivery
    view_pickup
    view_open
    )->
    console.log picked_tags
    self = @
    match = {}
    match.model = 'post'
    
    match.app = 'goldrun'
    # if view_open
    #     match.open = $ne:false
    # if view_delivery
    #     match.delivery = $ne:false
    # if view_pickup
    #     match.pickup = $ne:false
    # if Meteor.userId()
    #     if Meteor.user().downvoted_ids
    #         match._id = $nin:Meteor.user().downvoted_ids
    if query
        match.title = {$regex:"#{query}", $options: 'i'}
    
    if picked_tags.length > 0
        match.tags = $all: picked_tags
        # sort = 'price_per_serving'
    # if view_images
    #     match.is_image = $ne:false
    # if view_videos
    #     match.is_video = $ne:false

    # match.tags = $all: picked_tags
    # if filter then match.model = filter
    # keys = _.keys(prematch)
    # for key in keys
    #     key_array = prematch["#{key}"]
    #     if key_array and key_array.length > 0
    #         match["#{key}"] = $all: key_array
        # console.log 'current facet filter array', current_facet_filter_array

    # console.log 'product match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"#{sort_key}":sort_direction
        # sort:_timestamp:-1
        limit: limit

Meteor.publish 'facets', (
    query=''
    picked_tags=[]
    picked_location_tags=[]
    # picked_timestamp_tags=[]
    limit=10
    sort_key='_timestamp'
    sort_direction=-1
    view_delivery
    view_pickup
    view_open
    )->
        
    # console.log 'dummy', dummy
    # console.log 'query', query
    # console.log 'selected tags', picked_tags

    self = @
    match = {}
    match.model = 'post'
    match.app = 'goldrun'
    # if view_open
    #     match.open = $ne:false

    # if view_delivery
    #     match.delivery = $ne:false
    # if view_pickup
    #     match.pickup = $ne:false
    if picked_tags.length > 0 then match.tags = $all: picked_tags
    if picked_location_tags.length > 0 then match.location_tags = $all: picked_location_tags
    if query
        match.title = {$regex:"#{query}", $options: 'i'}

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        # { $nin: _id: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    tag_cloud.forEach (tag, i) =>
        # console.log 'tag result ', tag
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'tag'
            # category:key
            # index: i

    location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        # { $nin: _id: picked_location_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    location_cloud.forEach (location_tag, i) =>
        # console.log 'location_tag result ', location_tag
        self.added 'results', Random.id(),
            title: location_tag.title
            count: location_tag.count
            model:'location_tag'
            # category:key
            # index: i


    self.ready()

Meteor.publish 'some_posts', ->
    Docs.find {
        model:'post'
        app:'goldrun'
    }, limit:10
    
    
    
Meteor.methods
    increment_view: (doc_id)->
        Docs.update doc_id,
            $inc:
                views:1
            $set:
                last_viewed_timestamp:Date.now()


    insert_log: (type, user_id)->
        if type
            new_id = 
                Docs.insert 
                    model:'log_event'
                    log_type:type
                    user_id:user_id
    
    add_user: (username)->
        options = {}
        options.username = username

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'

    parse_keys: ->
        cursor = Docs.find
            model:'key'
        for key in cursor.fetch()
            # new_building_number = parseInt key.building_number
            new_unit_number = parseInt key.unit_number
            Docs.update key._id,
                $set:
                    unit_number:new_unit_number


    change_username:  (user_id, new_username) ->
        user = Docs.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "updated username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        Accounts.sendVerificationEmail(user_id, new_email)
        return "updated email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Docs.findOne username:username
        Accounts.removeEmail user_id, email


    verify_email: (user_id, email)->
        user = Docs.findOne user_id
        console.log 'sending verification', user.username
        Accounts.sendVerificationEmail(user_id, email)

    validate_email: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        re.test String(email).toLowerCase()


    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            to_user = Docs.findOne message.to_user_id

            message_link = "https://www.goldrun.online/user/#{to_user.username}/messages"

        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@goldrun.online"
                subject:"gold run message from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>view your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    order_food: (food_id)->
        food = Docs.findOne food_id
        Docs.insert
            model:'order'
            food_id: food._id
            order_price: food.price_per_serving
            buyer_id: Meteor.userId()
        Docs.update Meteor.userId(),
            $inc:credit:-food.price_per_serving
        Docs.update food.cook_user_id,
            $inc:credit:food.price_per_serving
        Meteor.call 'calc_food_data', food_id, ->

    calc_food_data: (food_id)->
        food = Docs.findOne food_id
        console.log food
        order_count =
            Docs.find(
                model:'order'
                food_id:food_id
            ).count()
        console.log 'order count', order_count
        servings_left = food.servings_amount-order_count
        console.log 'servings left', servings_left

        # food_dish =
        #     Docs.findOne food.dish_id
        # console.log 'food_dish', food_dish
        # if food_dish.ingredient_ids
        #     food_ingredients =
        #         Docs.find(
        #             model:'ingredient'
        #             _id: $in:food_dish.ingredient_ids
        #         ).fetch()
        #
        #     ingredient_titles = []
        #     for ingredient in food_ingredients
        #         console.log ingredient.title
        #         ingredient_titles.push ingredient.title
        #     Docs.update food_id,
        #         $set:
        #             ingredient_titles:ingredient_titles

        Docs.update food_id,
            $set:
                order_count:order_count
                servings_left:servings_left



    lookup_user: (username_query, role_filter)->
        if role_filter
            Docs.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                roles:$in:[role_filter]
                },{limit:10}).fetch()
        else
            Docs.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                },{limit:10}).fetch()


    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()


    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people


    set_password: (user_id, new_password)->
        console.log 'setting password', user_id, new_password
        Accounts.setPassword(user_id, new_password)



    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        console.log 'old count', old_count
        console.log 'new count', new_count
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

    send_enrollment_email: (user_id, email)->
        user = Docs.findOne(user_id)
        console.log 'sending enrollment email to username', user.username
        Accounts.sendEnrollmentEmail(user_id)
    