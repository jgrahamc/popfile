<?cs include "discussion-header.cs" ?>

<h1>Add Forum</h1>
<form class="add_form" method="post" action="<?cs var:discussion.href ?>">
  <fieldset>
    <legend>
       Add Forum:
    </legend>
    <div class="field">
      <label for="name">Name:</label><br/>
      <input type="text" id="name" name="name" value=""/><br/>
    </div>
    <div class="field">
      <label for="subject">Subject:</label><br/>
      <input type="text" id="subject" name="subject" value=""/><br/>
    </div>
    <div class="field">
      <label for="description">Description:</label><br/>
      <input type="text" id="description" name="description" value=""/><br/>
    </div>
    <div class="field">
      <label for="moderators">Moderators:</label><br/>
      <?cs if:discussion.users.0 ?>
        <select id="moderators" name="moderators" multiple="multiple">
          <?cs each:user = discussion.users ?>
            <option value="<?cs var:user ?>"><?cs var:user ?></option>
          <?cs /each ?>
        </select><br/>
      <?cs else ?>
        <input type="text" id="moderators" name="moderators" value=""/><br/>
      <?cs /if ?>
    </div>
    <?cs if:discussion.groups.1.id ?>
      <div class="group">
        <label for="group">Forum Group:</label><br/>
        <select id="group" name="group">
          <?cs each:group = discussion.groups ?>
            <option value="<?cs var:group.id ?>"><?cs var:group.name ?></option>
          <?cs /each ?>
        </select><br/>
      </div>
    <?cs else ?>
      <input type="hidden" id="group" name="group" value="0"/>
    <?cs /if ?>
    <div class="buttons">
      <input type="submit" name="submit" value="Submit"/>
      <input type="button" name="cancel" value="Cancel" onclick="location.href = '<?cs var:discussion.href ?>'"/>
      <input type="hidden" name="discussion_action" value="post-add"/>
    </div>
  </fieldset>
</form>

<?cs include "discussion-footer.cs" ?>
