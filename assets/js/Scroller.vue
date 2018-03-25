<script>
  import { ScrollContainer, ScrollItem } from 'vue-scrollmonitor'

export default {
  components: {
    ScrollContainer,
    ScrollItem,
    test: {
      functional: true,
        render: (h, { props }) => { console.log('refresh', props.state); return h('div', `${JSON.stringify(props.state)}${Math.random()}`) }
    }
  },
  data: () => ({
    state: {},
  }),
  methods: {
    updateState (state) {
      this.state = state
    },
    onChange (state) {
      console.log('change')
    },
  },
  computed: {
    itemsInViewport() {
        return _.pickBy(this.state, ({ isInViewport }) => isInViewport)
    }
  },
}
</script>

<template>
<div class="">
  <h1 class="white">Vue<span class="blue">ScrollMonitor</span></h1>
  <div>
    <Layout>
        <Header>Header</Header>
        <Layout>
            Sider
            Content

    <scroll-container @change="updateState" class="flex">
        <scroll-item :lock="true">
          <Sider >
            <!-- <prism language="javascript">{{ itemsInViewport }}</prism> -->
            <pre>
              {{ itemsInViewport }}
            </pre>
          </Sider>
        </scroll-item>

        <scroll-item v-for="i in 10" :id="i" :key="i" @change="onChange">
          <Content>
              <p>
                <Card :bordered="false">
                  <Button >{{i}}</Button>
              <!-- <Button :type=" state[i].isFullyInViewport  ? 'primary' : '' ">{{i}}</Button> -->
                </Card>
              </p>

          <!-- <p :class="`bloc mb4 mt0 pa6 f3 b tc white ${state[i] && state[i].isFullyInViewport ? 'bg-blue' : 'bg-light-blue'}`"> -->
            <!-- {{ i }} -->
          <!-- </p> -->
            </Content>
        </scroll-item>
    </scroll-container>

        </Layout>

        <Footer>Footer</Footer>
    </Layout>

  </div>
</div>
</template>

<style>
  /*
  html {
    background: #272822;
  }
  */
  
  .left {
    min-width: 480px;
  }
  .sidebar.isaboveviewport {
    position: fixed;
    top: 600px;
  }
  .bloc{
    transition: background-color .3s ease-in-out;
  }
</style>
