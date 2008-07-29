<?cs include "discussion-header.cs" ?>

<h1>Move Topic</h1>

<form class="move_form" method="post" action="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:discussion.topic.id ?>">
  <fieldset>
    <legend>
       Move Topic:
    </legend>
    <div class="field">
      <label for="new_forum">Forum:</label><br/>
      <select name="new_forum">
        <?cs each:forum = discussion.forums ?>
          <?cs if:discussion.topic.forum == forum.id ?>
            <option value="<?cs var:forum.id ?>" selected="selected"><?cs var:forum.name ?></option>
          <?cs else ?>
            <option value="<?cs var:forum.id ?>"><?cs var:forum.name ?></option>
          <?cs /if ?>
        <?cs /each ?>
      </select><br/>
    </div>
    <div class="buttons">
      <input type="submit" name="submit" value="Submit"/>
      <input type="submit" name="cancel" value="Cancel"/>
      <input type="hidden" name="discussion_action" value="post-move"/>
    </div>
  </fieldset>
</form>

<?cs include "discussion-footer.cs" ?>