<?cs def:discussion_sortable_th(order, asc, class, title, href) ?>
  <th class="<?cs var:class ?><?cs if:order == class ?> <?cs if:asc ?>asc<?cs else ?>desc<?cs /if ?><?cs /if ?>">
    <a title="Sort by <?cs var:class ?><?cs if:order == class ?><?cs if:!asc ?>(ascending)<?cs else ?>(descending)<?cs /if ?><?cs /if ?>" href="<?cs var:href ?>&amp;order=<?cs var:class ?><?cs if:order == class ?>&amp;asc=<?cs if:asc ?>0<?cs else ?>1<?cs /if ?><?cs /if ?>">
      <?cs var:title ?>
    </a>
  </th>
<?cs /def ?>

<?cs def:display_preview() ?>
  <li class="preview">
    <a name="preview"></a>
    <div class="id">
        Message #??
    </div>
    <div class="body">
      <?cs var:discussion.body ?>
    </div>
    <div class="footer">
      <div class="author">
        <?cs var:discussion.author ?>
      </div>
      <div class="time">
        <?cs var:discussion.time ?>
      </div>
    </div>
  </li>
<?cs /def ?>

<?cs def:display_reply_form() ?>
  <li class="reply">
    <fieldset>
      <a name="reply"></a>
      <legend>
         Reply:
      </legend>
      <form method="post" action="<?cs var:discussion.href ?>#preview">
        <div class="field">
          <label for="author">Author:</label><br/>
          <?cs if:discussion.authname == 'anonymous' ?>
            <input type="text" id="author" name="author" value="<?cs alt:args.author ?>anonymous<?cs /alt ?>"/><br/>
          <?cs else ?>
            <input type="text" id="author" name="author" value="<?cs var:discussion.authname ?>" readonly="readonly"/><br/>
          <?cs /if ?>
        </div>
        <div class="field">
          <label for="body">Body:</label><br/>
          <textarea id="body" name="body" class="wikitext" rows="10" cols="78"><?cs alt:args.body ?><?cs /alt ?></textarea>
          <br /><a href="/wiki/ForumFormatting" target="_blank">Formatting Syntax</a>
        </div>
        <div class="buttons">
          <input type="submit" name="preview" value="Preview"/>
          <input type="submit" name="submit" value="Reply"/>
          <input type="button" name="cancel" value="Cancel" onclick="location.replace('<?cs var:discussion.href ?>')"/>
        <?cs if:args.message ?>
          <input type="hidden" name="message" value="<?cs var:args.message ?>"/>
        <?cs /if ?>
        <input type="hidden" name="discussion_action" value="post-add"/>
        </div>
      </form>
    </fieldset>
  </li>
<?cs /def ?>

<?cs def:display_edit_form() ?>
  <fieldset>
    <a name="reply"></a>
    <legend>
      Edit:
    </legend>
    <form method="post" action="<?cs var:discussion.href ?>#preview">
      <?cs if:!args.message ?>
        <div class="field">
          <label for="subject">Subject:</label><br/>
          <input type="text" id="subject" name="subject" value="<?cs var:args.subject ?>"/><br/>
        </div>
      <?cs /if ?>
      <div class="field">
        <label for="body">Body:</label><br/>
        <textarea id="body" name="body" class="wikitext" rows="10" cols="78"><?cs var:args.body ?></textarea>
      </div>
      <div class="buttons">
        <input type="submit" name="preview" value="Preview"/>
        <input type="submit" name="submit" value="Submit changes"/>
        <input type="button" name="cancel" value="Cancel" onclick="location.replace('<?cs var:discussion.href ?>')"/>
      </div>
      <?cs if:args.message ?>
        <input type="hidden" name="message" value="<?cs var:args.message ?>"/>
      <?cs /if ?>
      <input type="hidden" name="discussion_action" value="post-edit"/>
    </form>
  </fieldset>
<?cs /def ?>

<?cs def:display_set_display() ?>
  <div class="set-display">
    <a href="<?cs var:discussion.href ?>?discussion_action=set-display;display=tree">Tree View</a>
    <a href="<?cs var:discussion.href ?>?discussion_action=set-display;display=flat-desc">Flat View (newer first)</a>
    <a href="<?cs var:discussion.href ?>?discussion_action=set-display;display=flat-asc">Flat View (older first)</a>
  </div>
<?cs /def ?>

<?cs def:display_replies(messages) ?>
  <?cs each:message = messages ?>
    <li class="message<?cs if:message.new ?> new<?cs /if ?>">
      <a name="<?cs var:message.id ?>"></a>
      <div class="id">
        Message #<?cs var:message.id ?>
      </div>
      <div class="body">
        <?cs if:(args.message == message.id) && !args.submit && ((args.discussion_action == 'edit') || (args.discussion_action == 'post-edit')) ?>
          <?cs var:discussion.body ?>
        <?cs else?>
        <?cs var:message.body ?>
        <?cs /if ?>
      </div>
      <div class="controls">
        <?cs if:trac.acl.DISCUSSION_APPEND ?>
          <a href="<?cs var:discussion.href ?>?discussion_action=add;message=<?cs var:message.id ?>#reply">Reply</a>
          <a href="<?cs var:discussion.href ?>?discussion_action=quote;message=<?cs var:message.id ?>#reply">Quote</a>
          <?cs if:discussion.is_moderator || ((message.author == discussion.authname) && (discussion.authname != 'anonymous')) ?>
            <a href="<?cs var:discussion.href ?>?discussion_action=edit;message=<?cs var:message.id ?>#reply">Edit</a>
          <?cs /if ?>
        <?cs /if ?>
        <?cs if:trac.acl.DISCUSSION_MODERATE && discussion.is_moderator ?>
          <a href="<?cs var:discussion.href ?>?discussion_action=delete;message=<?cs var:message.id ?>" onclick="return confirm('Do you realy want to delete this reply and all its descendants?')">Delete</a>
        <?cs /if ?>
      </div>
      <div class="footer">
        <div class="author">
          <?cs var:message.author ?>
        </div>
        <div class="time">
          <?cs var:message.time ?>
        </div>
      </div>
      <?cs if:(args.message == message.id) && !args.submit && ((args.discussion_action == 'edit') || (args.discussion_action == 'post-edit')) ?>
        <?cs call:display_edit_form() ?>
      <?cs /if ?>
    </li>
    <?cs if:message.replies.0.id || (args.message == message.id) && (((args.discussion_action == 'add') || (args.discussion_action == 'quote') || (args.discussion_action == 'post-add'))) ?>
      <li>
      <ul class="reply">
        <?cs if:message.replies.0.id ?>
          <?cs call:display_replies(message.replies) ?>
        <?cs /if ?>
          <?cs if:(args.message == message.id) && !args.submit && ((args.discussion_action == 'add') || (args.discussion_action == 'quote') || (args.discussion_action == 'post-add')) ?>
          <?cs if:args.preview ?>
            <?cs call:display_preview() ?>
          <?cs /if ?>
          <?cs call:display_reply_form() ?>
        <?cs /if ?>
      </ul>
      </li>
    <?cs /if ?>
  <?cs /each ?>
<?cs /def ?>

<?cs def:display_discussion(discussion) ?>
  <a name="-1"></a>
  <div class="topic <?cs if:discussion.topic.new ?>new<?cs /if ?>">
    <div class="header">
      <?cs if:!discussion.message.id && (args.discussion_action == 'edit' || args.discussion_action == 'post-edit') ?>
        <div class="subject">
          <?cs var:discussion.subject ?>
        </div>
        <div class="body">
          <?cs var:discussion.body ?>
        </div>
      <?cs else ?>
        <div class="subject">
          <?cs var:discussion.topic.subject ?>
        </div>
        <div class="body">
          <?cs var:discussion.topic.body ?>
        </div>
      <?cs /if ?>
    </div>
    <div class="controls">
      <?cs if:trac.acl.DISCUSSION_APPEND ?>
        <a href="<?cs var:discussion.href ?>?discussion_action=add;#reply">Reply</a>
        <a href="<?cs var:discussion.href ?>?discussion_action=quote;#reply">Quote</a>
        <?cs if:discussion.is_moderator || ((discussion.topic.author == discussion.authname) && (discussion.authname != 'anonymous'))?>
          <a href="<?cs var:discussion.href ?>?discussion_action=edit;#reply">Edit</a>
        <?cs /if ?>
      <?cs /if ?>
    </div>
    <div class="footer">
      <div class="author">
        <?cs var:discussion.topic.author ?>
      </div>
      <div class="time">
        <?cs var:discussion.topic.time ?>
      </div>
    </div>
    <?cs if:!args.message && !args.submit && ((args.discussion_action == 'edit') || (args.discussion_action == 'post-edit')) ?>
      <?cs call:display_edit_form() ?>
    <?cs /if ?>
  </div>

  <?cs if:discussion.messages.0.id || (args.discussion_action == 'add') || (args.discussion_action == 'quote') || (args.discussion_action == 'post-add') ?>
    <div class="replies <?cs if:discussion.topic.new ?>new<?cs /if ?>">
      <?cs call:display_set_display() ?>
      <ul class="reply">
        <?cs if:discussion.messages.0.id ?>
          <?cs call:display_replies(discussion.messages) ?>
        <?cs /if ?>
        <?cs if:!args.message && !args.submit && ((args.discussion_action == 'add') || (args.discussion_action == 'quote') || (args.discussion_action == 'post-add')) ?>
          <?cs if:args.preview ?>
            <?cs call:display_preview() ?>
          <?cs /if ?>
          <?cs call:display_reply_form() ?>
        <?cs /if ?>
      </ul>
      <?cs call:display_set_display() ?>
    </div>
  <?cs /if ?>
<?cs /def ?>
