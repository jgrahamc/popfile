<?cs include "discussion-header.cs" ?>

<h1>Add Topic</h1>

<?cs if:args.preview ?>
  <div class="message-list">
    <div class="topic">
      <div class="header">
        <div class="subject">
          <?cs var:discussion.subject ?>
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
      </div>
    </div>
  </div>
<?cs /if ?>

<form class="add_form" method="post" action="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>">
  <fieldset>
    <legend>
       Add Topic:
    </legend>
    <div class="field">
      <label for="author">Author:</label><br/>
      <?cs if:discussion.authname == 'anonymous' ?>
        <input type="text" id="author" name="author" value="<?cs alt:args.author ?>anonymous<?cs /alt ?>"/><br/>
      <?cs else ?>
        <input type="text" id="author" name="author" value="<?cs var:discussion.authname ?>" readonly="readonly"/><br/>
      <?cs /if ?>
    </div>
    <div class="field">
      <label for="subject">Subject:</label><br/>
      <input type="text" id="subject" name="subject" value="<?cs var:args.subject ?>"/><br/>
    </div>
    <div class="field">
      <label for="body">Body:</label><br/>
      <textarea id="body" name="body" class="wikitext" rows="10" cols="78"><?cs alt:args.body ?><?cs /alt ?></textarea>
      <br /><a href="/wiki/ForumFormatting" target="_blank">Formatting Syntax</a>
    </div>
    <div class="buttons">
      <input type="submit" name="preview" value="Preview"/>
      <input type="submit" name="submit" value="Submit"/>
      <input type="button" name="cancel" value="Cancel" onclick="location.href = '<?cs var:discussion.href?>/<?cs var:discussion.forum.id ?>'"/>
      <input type="hidden" name="discussion_action" value="post-add"/>
    </div>
  </fieldset>
</form>

<?cs include "discussion-footer.cs" ?>
