<?cs include:"discussion-macros.cs"?>

<?cs linclude "discussion-header.cs" ?>

<h1><a href="/discussion/<?cs var:discussion.forum.id ?>"><?cs var:discussion.forum.name ?></a> &rarr; <?cs var:discussion.topic.subject ?></h1>
<?cs set:discussion.href = discussion.href + '/' + discussion.forum.id + '/' + discussion.topic.id ?>
<?cs call:display_discussion(discussion) ?>
<?cs if:trac.acl.DISCUSSION_MODERATE && discussion.is_moderator ?>
  <div class="buttons">
    <form method="post" action="<?cs var:discussion.href ?>">
      <div>
        <input type="submit" name="deletetopic" value="Delete Topic" onclick="return confirm('Do you realy want to delete this topic?')"/>
        <input type="hidden" name="discussion_action" value="delete"/>
      </div>
    </form>
    <form method="post" action="<?cs var:discussion.href ?>">
      <div >
        <input type="submit" name="movetopic" value="Move Topic"/>
        <input type="hidden" name="discussion_action" value="move"/>
      </div>
    </form>
  </div>
<?cs /if ?>

<?cs linclude "discussion-footer.cs" ?>
