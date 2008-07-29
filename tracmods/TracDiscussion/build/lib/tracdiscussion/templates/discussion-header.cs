<?cs include "header.cs" ?>

<div id="ctxtnav" class="nav">
  <h2>Wiki Navigation</h2>
  <?cs if:discussion.forum.id ?>
  <ul>
      <?cs if:discussion.topic.id ?>
        <li>
          <a href="<?cs var:discussion.href ?>">Forum Index</a>
        </li>
        <?cs if:discussion.message.id ?>
          <li>
            <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>">
              <?cs var:discussion.forum.subject ?>
            </a>
          </li>
          <li class="last">
            <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:discussion.topic.id ?>">
              <?cs var:discussion.topic.subject ?>
            </a>
          </li>
        <?cs else ?>
          <li class="last">
            <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>">
              <?cs var:discussion.forum.subject ?>
            </a>
          </li>
        <?cs /if ?>
      <?cs else ?>
        <li class="last">
          <a href="<?cs var:discussion.href ?>">Forum Index</a>
        </li>
      <?cs /if ?>
    </ul>
    <?cs /if ?>
  <hr/>
</div>

<div id="content" class="discussion">
<div id="<?cs var:discussion.mode ?>" class="<?cs var:discussion.mode ?>">
