<?cs include:"discussion-macros.cs" ?>

<div id="message-list" class="message-list">
  <?cs if:trac.acl.DISCUSSION_VIEW ?>
    <?cs if:discussion.topic.id ?>
      <?cs linclude:"wiki-discussion-header.cs"?>
      <?cs call:display_discussion(discussion) ?>
      <?cs linclude "wiki-discussion-footer.cs" ?>
    <?cs else?>
      <?cs linclude:"wiki-discussion-missing.cs" ?>
    <?cs /if ?>
  <?cs else ?>
    <?cs linclude:"wiki-discussion-denied.cs" ?>
  <?cs /if ?>
</div>
